
classify(Sepal_length, Sepal_width, Petal_length, Petal_width) :-
    (
        Sepal_width >= 2.0,
        Sepal_width =< 4.4,
        Petal_width =< 0.80,
        write('Iris-setosa')
    ;
        Petal_width > 0.80,
        Petal_width =< 1.75,
        (
            Petal_length =< 4.95,
            Petal_width =< 1.65,
            write('Iris-versicolor')
        ;
            Petal_length =< 4.95,
            Petal_width > 1.65,
            write('Iris-virginica')
        ;
            Petal_length > 4.95,
            Petal_width =< 1.55,
            write('Iris-virginica')
        ;
            Petal_length > 4.95,
            Petal_width > 1.55,
            Sepal_length =< 6.95,
            write('Iris-versicolor')
        ;
            Petal_length > 4.95,
            Petal_width > 1.55,
            Sepal_length > 6.95,
            write('Iris-virginica')
        )
    ;
        Petal_width > 1.75,
        Petal_width =< 1.8,
        Petal_length =< 4.85,
        Sepal_length =< 5.95,
        write('Iris-versicolor')
    ;
        Petal_width > 1.75,
        Petal_length =< 4.85,
        Sepal_length > 5.95,
        Sepal_length =< 7.9,
        write('Iris-virginica')
    ;
        Petal_width > 1.75,
        Petal_width =< 2.5,
        Petal_length > 4.85,
        Petal_length =< 6.9,
        write('Iris-virginica')
    ).
