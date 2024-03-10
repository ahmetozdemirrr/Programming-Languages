(defun is-alphanumeric-char (char)
    (alphanumericp char)
)

(defun my-string-match-p (regex string)
    (let ((regex-length (length regex))
          (string-length (length string))
          (found nil))

    (loop for i from 0 to (- string-length regex-length)
          until (and (string= regex (subseq string i (+ i regex-length)))
                     (setq found t)
                )
    )
    found
    )
)

(defun classify-token (token)
  (cond
    ((equal token "+") 'OP_PLUS)
    ((equal token "-") 'OP_MINUS)
    ((equal token "*") 'OP_MULT)
    ((equal token "/") 'OP_DIV)
    ((equal token "(") 'OP_OP)
    ((equal token ")") 'OP_CP)
    ((equal token ",") 'OP_COMMA)
    ((equal token "true") 'KW_TRUE)
    ((equal token "false") 'KW_FALSE)
    ((equal token "and") 'KW_AND)
    ((equal token "or") 'KW_OR)
    ((equal token "not") 'KW_NOT)
    ((equal token "equal") 'KW_EQUAL)
    ((equal token "less") 'KW_LESS)
    ((equal token "nil") 'KW_NIL)
    ((equal token "list") 'KW_LIST)
    ((equal token "append") 'KW_APPEND)
    ((equal token "concat") 'KW_CONCAT)
    ((equal token "set") 'KW_SET)
    ((equal token "for") 'KW_FOR)
    ((equal token "if") 'KW_IF)
    ((equal token "load") 'KW_LOAD)
    ((equal token "disp") 'KW_DISP)
    ((equal token "exit") 'KW_EXIT)
    ((equal token "def") 'KW_DEF)
    ((my-string-match-p "[0-9]+" token) 'VALUEI)
    ((my-string-match-p "[0-9]+b[0-9]+" token) 'VALUEF)
    ((my-string-match-p "[a-zA-Z][a-zA-Z0-9]*" token) 'IDENTIFIER)
    (t 'IDENTIFIER)
  )
)

(defun lex-token (input)
    (loop for char across input
        
        with tokens = '()
        with current-token = ""
        
        do 
        (cond
            ((find char " \t\n")
                (when current-token
                    (push (classify-token (string-trim " " current-token)) tokens)
                    (setq current-token "")
                )
            )

            ((find char "+-*/(),")
                (when current-token
                    (push (classify-token current-token) tokens)
                    (setq current-token "")
                )
                (push (string char) tokens)
            )

            ((is-alphanumeric-char char)
                (setq current-token (concatenate 'string current-token (string char)))
            )

            (t (format t "Syntax Error ~a~% cannot be tokenized" char))
        )

        finally (when current-token
                    (push (classify-token (string-trim " " current-token)) tokens)
                )
        finally (return (reverse tokens))
    )
)

(defun analyze-tokens (tokens)
    (loop for token in tokens do
        (format t "~a~%" token)
    )
)

(let ((input "if 23b34 not * - % x + 10"))

    (let ((tokens (lex-token input)))
        (analyze-tokens tokens)
    )
)