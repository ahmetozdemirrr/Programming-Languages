; ****************************** CFG TEMPLATES ******************************
; *																			*
; *	 non-terminals :														*
; *																			*
; *	 $START  :=  ɛ | $START $INPUT ;										*
; *																			*
; *	 $INPUT  :=  $EXIT | $EXP | $DEF_FUNC ;									*
; *																			*
; *	 $EXIT   :=  OP_OP KW_EXIT OP_CP ;										*
; *																			*
; *	 $EXP    :=    OP_OP OP_PLUS    EXP EXP OP_CP ->						*
; *			  	 | OP_OP OP_MINUS   EXP EXP OP_CP  ; ARITMETIC OPERATIONS	*
; *			  	 | OP_OP OP_DIV     EXP EXP OP_CP							*
; *			  	 | OP_OP OP_MULT    EXP EXP OP_CP  ^						*
; *			  	 | OP_OP IDENTIFIER EXP EXP OP_CP ->						*
; *			  	 | OP_OP IDENTIFIER     EXP OP_CP	; FUNCTION CALL 		*
; *			  	 | OP_OP IDENTIFIER         OP_CP  ^						*
; *			  	 | VALUEF 													*
; *			     ;															*
; *																			*
; *	 $DEF_FUNC :=  OP_OP KW_DEF IDENTIFIER IDENTIFIER IDENTIFIER EXP OP_CP	*
; *			     | OP_OP KW_DEF IDENTIFIER IDENTIFIER            EXP OP_CP	*
; *			     | OP_OP KW_DEF IDENTIFIER 					     EXP OP_CP	*
; *				 ;															*
; *																			*
; *   terminals :  OP_OP | OP_CP | OP_MINUS | OP_PLUS | OP_DIV | OP_MULT |	*
; *  				KW_DEF | KW_EXIT | VALUEF | IDENTIFIER					*
; *																			*
; ***************************************************************************

(defconstant *output-file-name* "output.txt") ; sonuçların yazılacağı dosya

(defstruct function-info  ;; fonksiyon yapısı

	name      		; name of function
	operator  		; body of function (exp içindeki operatörü tutar)
	operand1  		; first  argument of function (optional)
	operand2  		; second argument of function (optional)
	argument-number ; number of arguments
)

; fonksiyonları tutan hash-map
(defvar *function-table* (make-hash-table :test 'equal)) ; burada test, fonksiyon bilgilerine erişebilmek için anahtar görevi görür

(defvar *exit-flag*  nil)

; interpreter'ı başlatan fonksiyon
(defun gppinterpreter (&optional file-names) ; eğer opsiyonel olarak bir dosya ismi geliyorsa dosyadan input okur 
    
    (let ((out-stream (open *output-file-name* :direction :output))) ; outpur'ların yazılacağı dosyayı açar
        
        (if file-names ; file belirtilmişse

            (mapcar #'(lambda (file-name) (parser (gpp-lexer file-name) out-stream)) file-names) ; dosya için lexer ve parser çağırıyoruz
            (parser (gpp-lexer) out-stream) ; lexer'da komut satırından input alıp parser'ı çağır
        )
        (close out-stream) ; çıkış dosyasını kapat
    )
)

(defun parser (tokens out-stream)
    
    (if (null tokens) (return-from parser nil)) ; tokens listesi boşsa -> return nil
    
    (let ((result nil) (out-val nil)) ; inputun verdiği sayısal işlem -> out-val, tokens listesi -> result
        
        (setq result (START tokens)) ; $START non-terminalinden dönen liste => result
        (setq out-val (car result)) ; gelen result'ın ilk değeri sonucu taşır onu car ile out-val'e atıyoruz

        (if out-val ; out-val bir değer taşıyor mu?
            
            (progn ; true -> 
                
                (format out-stream "~a~%" 
                    (if (numberp out-val) (format-valuef out-val) out-val)
                )

                (format t "~a~%" 
                    (if (numberp out-val) (format-valuef out-val) out-val)
                )
                
                (if (not *exit-flag*) ; eğer exit flag false ise buraya gir
                    (parser (cadr result) out-stream) ; gpp - parser'ı tekrar çağır ve tekrar input al
                )
            )

            (progn
            	
            	(format out-stream "Syntax Error!~%") ; false -> eğer bir değer taşımıyorsa ya da lexer'dan değer dönülmemişse Syntax Error hatası verilir ve program sona erdirilir
                (format t "Syntax Error!~%") ; false -> eğer bir değer taşımıyorsa ya da lexer'dan değer dönülmemişse Syntax Error hatası verilir ve program sona erdirilir
            )
        )
        (car result)
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ~ CFG RULES START ~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun START (tokens) ; evaluating START non-terminal

    (INPUT tokens) ; calling INPUT non-terminal with same parameter
)

(defun INPUT (tokens) ; evaluating INPUT non-terminal
    
    (let ((result))	;; INPUT := EXIT-PROGRAM | EXP | FUNCTION ;

        (cond 
            ((car (setq result (EXIT-PROGRAM  tokens))) result)
            ((car (setq result (EXPR          tokens))) result)
            ((car (setq result (DEF_FUNC     tokens))) result)
        )
    )
)

(defun EXIT-PROGRAM (tokens) ; evaluating EXIT non-terminal
    
    (let ((result nil))  ;; EXIT-PROGRAM := OP_OP KW_EXIT OP_CP
        
        (if (string= (next-token tokens) "OP_OP") ; current eleman OP_OP mu?
            
            (setq tokens (cdr tokens)) 	; true -> current elemanı listeden sil
            (return-from EXIT-PROGRAM (evaluate-res nil tokens)) ; false -> return nil
        ) 
        
        (if (string= (next-token tokens) "KW_EXIT") ; current eleman KW_EXIT mı?     
            
            (setq tokens (cdr tokens))	; true -> current elemanı listeden sil
            (return-from EXIT-PROGRAM (evaluate-res nil tokens)) ; false -> return nil
        )
        
        (if (string= (next-token tokens) "OP_CP") ; current eleman OP_CP mi?
        
            (progn ; true ->
            
                (setq *exit-flag* t) ; exit-flag değişkenini t olarak ayarla
                (setq result (evaluate-res "$_" tokens)) ; result ata
            )
            (return-from EXIT-PROGRAM (evaluate-res nil tokens)) ; false -> return nil
        )
    result
    )
)

(defun EXPR (tokens) ; evaluating EXP non-terminal
    
    (let ((result)) ; EXP := ARITHMETIC | IDENTIFIER | VALUEF | FCALL
        
        (cond 

            ((car (setq result (ARITHMETIC tokens))) result)        
            ((car (setq result (IDENTIFIER tokens))) result)
            ((car (setq result (VALUEF 	tokens))) result)
            ((car (setq result (FUNCTION-CALL  	tokens))) result)

            (t (evaluate-res nil tokens))
        )
    )
)

(defun ARITHMETIC (tokens) ; evaluating ARITHMETIC non-terminal 

    (let ( (result nil) (param1 nil) (param2 nil) (operator nil)) ; ARITHMETIC := OP_OP (OP_PLUS | OP_MINUS | OP_MULT | OP_DIV) EXP EXP OP_CP
        
        (if (string= (next-token tokens) "OP_OP") ; current eleman OP_OP mu?
            
            (setq tokens (cdr tokens)) ; true -> current elemanı listeden sil
            (return-from ARITHMETIC (evaluate-res nil tokens))	; false -> return nil
        ) 
        
        (if (is-my-operator (next-token tokens)) ; current tanımlı bir operatör mü?
            
            (progn ; true ->
                
                (setq operator (next-token tokens))	; operatore atama yap
                (setq tokens   (cdr tokens)) ; current elemanı listeden sil
            )
            (return-from ARITHMETIC (evaluate-res nil tokens)) ; false -> return nil
        )
        
        (setq result (EXPR tokens)) ; $EXP non-terminaline git ve EXP ifadesinin karşılığını al

        (if (car result) ; EXP içinde eleman var mı?
            
            (progn ; true ->
                
                (setq param1 (car  result))	; param1'e atama yap
                (setq tokens (cadr result))	; güncel token listesini tokens'a set et
            )
            (return-from ARITHMETIC (evaluate-res nil tokens)) ; false -> return nil
        )
 
        (setq result (EXPR tokens))	; $EXP non-terminaline git ve EXP ifadesinin karşılığını al

        (if (car result) ; EXP içinde eleman var mı?
            
            (progn ; true ->
                
                (setq param2 (car  result))	; param2'ye atama yap
                (setq tokens (cadr result))	; güncel token listesini tokens'a set et
            )
            (return-from ARITHMETIC (evaluate-res nil tokens))	; false -> return nil
        )
        
        (if (string= (next-token tokens) "OP_CP") ; current (son) eleman OP_CP mi?
                  
            (setq result (evaluate-res (evaluate-valuef operator param1 param2) tokens)) ; normal işlem devam etsin
            (return-from ARITHMETIC (evaluate-res nil tokens)) ; false -> return nil
        )
    result
    )
)

(defun DEF_FUNC (tokens)
  
  	(let ((result nil) (name nil) (operator nil) (param1 nil) (param2 nil) (operand1 nil) (operand2 nil) (argument-number 0))

	    ; OP_OP kontrolü
	    (if (string= (next-token tokens) "OP_OP")
	    
	        (setq tokens (cdr tokens))
	        (return-from DEF_FUNC (evaluate-res nil tokens))
	    )

	    ; KW_DEF kontrolü
	    (if (string= (next-token tokens) "KW_DEF")
	        
	        (setq tokens (cdr tokens))
	        (return-from DEF_FUNC (evaluate-res nil tokens))
	    )

		; IDENTIFIER (fonksiyon adı) kontrolü
		(setq result (IDENTIFIER tokens))

		(if (car result)
		    
		    (progn
		    
		        (setq name (car result))
		        (setq tokens (cadr result))

		        ;; Fonksiyon adının hash-map'te zaten tanımlı olup olmadığını kontrol et
		        (if (gethash name *function-table*)
		            
		            (progn
		                ;; Fonksiyon adı zaten tanımlı, hata ver ve çık
		                (format t "Function ~s is already defined~%" name)
		                (return-from DEF_FUNC (evaluate-res nil tokens))
		            )
		        )
		    )
		    (return-from DEF_FUNC (evaluate-res nil tokens))
		)

	    ; Parametreleri işle (eğer varsa)
	    (setq result (IDENTIFIER tokens))

	    (if (car result)
	        
	        (progn

	          	(setq tokens (cadr result))
            	(incf argument-number)
	        )
	        ; parameter is optional
	        ; (return-from DEF_FUNC (evaluate-res nil tokens))
	    )

	    ; Parametreleri işle (eğer varsa)
	    (setq result (IDENTIFIER tokens))

	    (if (car result)
	    
	        (progn
	    
	            (setq tokens (cadr result))
	            (incf argument-number)
	        )
	        ; parameter is optional
	        ; (return-from DEF_FUNC (evaluate-res nil tokens))
	    )

	    ; OP_OP kontrolü
	    (if (string= (next-token tokens) "OP_OP")
	    	
	    	(setq tokens (cdr tokens))
	        (return-from DEF_FUNC (evaluate-res nil tokens))
	    )

	    ; OPERATOR kontrolü
	    (setq operator (next-token tokens))
	    
	    (unless (is-my-operator operator)
	    
	      	(return-from DEF_FUNC (evaluate-res nil tokens))
	    )
	    (setq tokens (cdr tokens))

	    ; Operandları işle
	    (setq result (OPERAND tokens))
	    
	    (if (car result)
	    
	        (progn

	            (if (equal (type-of (car result)) (intern "RATIO"))

		            (progn

		            	(setq operand1 (car result))
		            )
		        )
	            (setq tokens (cadr result))
	        )
	        (return-from DEF_FUNC (evaluate-res nil tokens))
	    )

	    (setq result (OPERAND tokens))

	    (if (car result)
	    
	        (progn

	            (if (equal (type-of (car result)) (intern "RATIO"))

		            (progn

		            	(setq operand2 (car result))
		            )		        
		        )
		        (setq tokens (cadr result))
	        )
	        (return-from DEF_FUNC (evaluate-res nil tokens))
	    )

	    ; OP_CP kontrolü
	    (unless (string= (next-token tokens) "OP_CP")
	        
	        (return-from DEF_FUNC (evaluate-res nil tokens))
	    )
	    (setq tokens (cdr tokens))

	    ; OP_CP kontrolü
	    (if (string= (next-token tokens) "OP_CP")
	        
	        (progn

	        	; Syntax Error olmadığına göre tanımı yap
			    (setf (gethash name *function-table*) 
			    	
			    	(make-function-info :name name 
			    						:operator operator
			    						:operand1 operand1
			    						:operand2 operand2
			    						:argument-number argument-number
			    	)
			    )
			    (setq result (evaluate-res "#function" tokens))
	        )
	        (return-from DEF_FUNC (evaluate-res nil tokens))
	    )
	    (setq tokens (cadr tokens))

	    ;(maphash #'print-hash-table *function-table*)
	    
		result
	)
)

(defun FUNCTION-CALL (tokens)

	(let ((result nil) (name nil) (operator nil) (parameter1 nil) (parameter2 nil) (argument1 nil) (argument2 nil) (argument-number nil))

		; OP_OP kontrolü
		(if (string= (next-token tokens) "OP_OP")
		
			(progn

				(setq tokens (cdr tokens))
			)
			(return-from FUNCTION-CALL (evaluate-res nil tokens))
		)

		; IDENTIFIER (fonksiyon adı) kontrolü
		(setq result (IDENTIFIER tokens))

		(if (car result)
		    
		    (progn
		    
		        (setq name (car result))
		        (setq tokens (cadr result))

		        ;; Fonksiyon adının hash-map'te tanımlı olup olmadığını kontrol et
		        (if (not (gethash name *function-table*))
		            
		            (progn
		                ;; Fonksiyon adı tanımlı değil, hata ver ve çık
		                (format t "Undefined Function: ~s~%" name)
		                (return-from FUNCTION-CALL (evaluate-res nil tokens))
		            )

		            (progn
		            	
						(let ((function-info (gethash name *function-table*)))


	            			(setq name 					 (function-info-name     function-info))
	            			(setf operator 		         (function-info-operator function-info))
	            			(setf argument1 			 (function-info-operand1 function-info))
	            			(setf argument2 			 (function-info-operand2 function-info))
	            			(setf argument-number (function-info-argument-number function-info))
		            	)
		            )
		        )
		    )
		    (return-from FUNCTION-CALL (evaluate-res nil tokens))
		)

	    ; VALUEF (parametre1 tip) kontrolü
	    (setq result (OPERAND tokens))
	    
	    (if (car result)
	    
	        (progn
	    		
	          	(setq parameter1 (car result))
	         	(setq tokens (cadr result))
	        )
	        ;(return-from FUNCTION-CALL (evaluate-res nil tokens))
	    )

	    ; VALUEF (parametre2 tip) kontrolü
	    (setq result (OPERAND tokens))
	    
	    (if (car result)
	    
	        (progn
	    
	          	(setq parameter2 (car result))
	         	(setq tokens (cadr result))
	        )
	        ;(return-from FUNCTION-CALL (evaluate-res nil tokens))
	    )

		; OP_CP kontrolü
	    (if (string= (next-token tokens) "OP_CP")

	    	(progn

	    		(if (= argument-number 0)
	    			
	    			(setq result (evaluate-res (evaluate-valuef operator argument1 argument2) tokens))
	    		)

    			(if (= argument-number 1)
    				
    				(setq result (evaluate-res (evaluate-valuef operator parameter1 argument2) tokens))
    			)

			    (if (= argument-number 2)
					
					(setq result (evaluate-res (evaluate-valuef operator parameter1 parameter2) tokens))
				)
	    	)
	        (return-from FUNCTION-CALL (evaluate-res nil tokens))
	    )
	    (setq tokens (cadr tokens))

	    result
	)
)

(defun IDENTIFIER (tokens) ; it is a terminal symbol

	;; IDENTIFIER := IDENTIFIER ($$ = $1 in yacc)
	(if (string= (next-token tokens) "IDENTIFIER")
		
		(evaluate-res (next-value tokens) tokens)
		(evaluate-res nil tokens)
	)
)

(defun VALUEF (tokens) ; it is a terminal symbol

	; VALUEF := VALUEF ($$ = $1 in yacc)
	(let ((token (next-token tokens)) (variable nil))
		
		(if (string= token "VALUEF")
			(setq variable (next-value tokens))
		)
		(evaluate-res variable tokens)
	)
)

(defun OPERAND (tokens) ;; fonksiyon tanımlanırken içerideki operand
  
    (let ((result nil))

	    ; Operand olarak bir değişkenin tanımlandığı durumu kontrol et
	    (setq result (IDENTIFIER tokens))
	    (if (car result)
	        
	        (progn
	          	
	          	(setq tokens (cadr result))
	            (return-from OPERAND result)
	        )
	    )

	    ; Operand olarak bir sayısal ifadeyi kontrol et (örneğin, VALUEF)
	    (setq result (VALUEF tokens))
	    (if (car result)
	        
	        (progn
	            
	            (setq tokens (cadr result))
	            (return-from OPERAND result)
	        )
	    )
	    ; Tanımsız operand durumu için Syntax Error
	    (return-from OPERAND (evaluate-res nil tokens))
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ~ CFG RULES END ~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun evaluate-valuef (operator param1 param2) ; evaluating VALUEF
    
    (cond
        
        ;;Arithmetic Operations;;
        ((string= operator  "OP_PLUS") (+ param1 param2))
        ((string= operator "OP_MINUS") (- param1 param2))
        ((string= operator   "OP_DIV") (/ param1 param2))
        ((string= operator  "OP_MULT") (* param1 param2))
    )
)

(defun print-hash-table (key value)

    (format t "~a: ~a~%" key value)
)

(defun is-my-operator (str)

    (or (string= str "OP_PLUS") (string= str "OP_MINUS") (string= str "OP_MULT") (string= str "OP_DIV"))
)

(defun evaluate-res (flag token-list)

    (if flag (cons flag (list (cdr token-list))) (cons flag (list token-list)))
)

(defun next-token (token-list) 

    (cadar token-list)
)

(defun next-value (token-list)

    (caar token-list)
)

(defun format-valuef (valuef)

    (format nil "~sb~s" (numerator valuef) (denominator valuef))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ~ LEXER PART START ~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setf keywords 

    '( 
        ("and"       "KW_AND") 
        ("or"         "KW_OR") 
        ("not"       "KW_NOT") 
        ("equal"   "KW_EQUAL") 
        ("less"     "KW_LESS") 
        ("nil"       "KW_NIL") 
        ("list"     "KW_LIST")
        ("append" "KW_APPEND") 
        ("concat" "KW_CONCAT") 
        ("set"       "KW_SET") 
        ("def"       "KW_DEF") 
        ("for"       "KW_FOR") 
        ("if"         "KW_IF")
        ("while"   "KW_WHILE")
        ("exit"     "KW_EXIT") 
        ("load"     "KW_LOAD") 
        ("disp"     "KW_DISP") 
        ("true"     "KW_TRUE") 
        ("false"   "KW_FALSE")
    )
)

(setf operators-alist 
    
    '(
        ("+" "OP_PLUS")
        ("-" "OP_MINUS") 
        ("/" "OP_DIV") 
        ("*" "OP_MULT") 
        ("(" "OP_OP") 
        (")" "OP_CP")
        ("," "OP_COMMA")
    )
)

(setf exit-flag nil)

(setf token-list())  ; our tokens
(setf unmached-token "") ; unmached token during tokenization process

(defun gpp-lexer (&optional filename)

    (if filename
    
        (input-file filename)
        (input-command-line)
    )
    (setf tokens(reverse token-list))
)

(defun input-file (filename)

    (with-open-file (stream filename) 
        
        (loop :for curr-char := (read-char stream nil) :while curr-char :do
        
            (tokenize curr-char)
        )
    )
)

(defun input-command-line ()

    (format t "> ") 

    (loop :for curr-char := (read-char nil) :do
        
        (tokenize curr-char)
        
        (cond 
        
            (exit-flag (return-from input-command-line nil))
            
            ((char= curr-char #\Newline)
                
                (progn

                    (format t "> ")
                )   
            )
        )
    )
)

(defun tokenize (curr-char)

    (cond

        (
            (seperates curr-char)

            (if (> (length unmached-token) 0)
                
                (progn 
                
                    (setf result nil)
                
                    (cond                        
                        ; KEYWORD
                        ((setf result (map-keyword unmached-token))

                            (if (string= unmached-token "exit") 
                            
                                (setf exit-flag t)
                            )
                            
                            (push result token-list)
                        )
                        
                        ; OPERATOR
                        ((setf result (map-operator unmached-token))
                        
                            (push result token-list)
                        )
                        
                        ; VALUEF
                        ((is-valuef unmached-token)
                        
                            (push (list (parse-rational unmached-token) "VALUEF") token-list)
                        )
                        
                        ; IDENTIFIER
                        ((is-identifier unmached-token)
                        
                            (push (list unmached-token "IDENTIFIER") token-list)
                        )
                        
                        ; SYNTAX-ERROR
                        (t
                            nil
                        )
                    )                        
                    (setf unmached-token "")
                )
            )
            (if (or (string= curr-char "(") (string= curr-char ")"))
            
                (push (map-operator curr-char) token-list)
            )
        )

        (t
            (setf unmached-token (concat-end unmached-token curr-char))
        )
    )          
)

(defun is-legal-token (sample)

    (is-legal-token-helper sample 0 (length sample)) 
)

(defun is-legal-token-helper (sample curr end)
    
    (if (eq curr end)
    
        t
    
        (progn 
            
            (setf c (char sample curr))

            (if (or (is-digit c) (is-alpha c) (char= c #\_) (map-operator c))
            
                (is-legal-token-helper sample (1+ curr) end)
                nil
            )
        )
    )
)

(defun is-leading-zero (sample)
    
    (setf first-char (char sample 0))
    
    (if (char= first-char #\0)
        
        (if (eq (length sample) 1) 
        
            nil
            t
        )
        nil
    )
)

(defun is-digit (sample)

    (setf ascii (char-code sample))
    (and (>= ascii (char-code #\0)) (<= ascii (char-code #\9)))
)

(defun is-alpha (sample)
    
    (setf ascii (char-code sample))
    
    (or 
        (and (>= ascii (char-code #\a)) (<= ascii (char-code #\z))) 
        (and (>= ascii (char-code #\A)) (<= ascii (char-code #\Z)))
    )
)

(defun is-valuef (sample)

    (if (is-leading-zero sample)
    
        nil ;; leading zero error
        (is-valuef-helper sample 0 (length sample) nil)
    )
)

(defun is-valuef-helper (sample curr end temp-valuef)
    
    (cond 
        
        ((eq curr end) t)
        
        ((is-digit (char sample curr))
        
            (is-valuef-helper sample (1+ curr) end temp-valuef)
        )
        
        (temp-valuef nil)

        ((char= (char sample curr) #\b)
        
            (is-valuef-helper sample (1+ curr) end t)
        )
        (t nil)
    )
)

(defun parse-rational (valuef)

    (let ((i (position #\b valuef)) (num nil) (denom nil))
        
        (cond
            
            ((null i) nil)
            
            (t 
                (setq num   (parse-integer (subseq valuef   0 i)))
                (setq denom (parse-integer (subseq valuef (1+ i))))
                (/ num denom)
            )
        )
    )
)

(defun seperates (sample)
    
    (or
        (char= sample #\Space)
        (char= sample #\Newline)
        (char= sample #\Tab)
        (string= sample "(")
        (string= sample ")")
    )
)

(defun is-identifier (sample)

    (setf firstLetter (char sample 0))
    
    (if (or (is-alpha firstLetter) (char= firstLetter #\_))
    
        (is-identifier-helper sample 1 (length sample))
        nil
    )
)

(defun is-identifier-helper (sample curr end)

    (if (eq curr end) 
        
        t
    
        (progn
        
            (setf c (char sample curr))
        
            (if (or (is-alpha c) (is-digit c) (char= c #\_))
        
                (is-identifier-helper sample (1+ curr) end)
                nil
            )
        )
    )
)

(defun concat-end (s1 s2)
    (concatenate 'string s1 (string s2))   
)

(defun map-operator (key)
    (assoc key operators-alist :test #'string=)
)

(defun map-keyword (key)
    (assoc key keywords :test #'string=)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ~ LEXER PART END ~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(gppinterpreter *args*)