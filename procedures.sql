-- Procedure para cadastrar aluno:

CREATE PROCEDURE cadastra_aluno
    @nome VARCHAR(50)
AS
BEGIN
    INSERT INTO ALUNOS (NOME)
    VALUES (@nome)
END

-- Procedure para cadastrar professor:

CREATE PROCEDURE cadastra_professor
    @nome VARCHAR(50)
AS
BEGIN
    INSERT INTO PROFESSOR (NOME)
    VALUES (@nome)
END

-- Procedure para cadastrar matéria:

CREATE PROCEDURE cadastra_materia
    @sigla CHAR(3),
    @nome VARCHAR(50),
    @cargahoraria INT,
    @curso CHAR(3),
    @professor INT
AS
BEGIN
    INSERT INTO MATERIAS (SIGLA, NOME, CARGAHORARIA, CURSO, PROFESSOR)
    VALUES (@sigla, @nome, @cargahoraria, @curso, @professor)
END

-- Procedure para cadastrar curso:

CREATE PROCEDURE cadastra_curso
    @curso CHAR(3),
    @nome VARCHAR(50)
AS
BEGIN
    INSERT INTO CURSOS (CURSO, NOME)
    VALUES (@curso, @nome)
END

-- Procedure para matricular alunos

CREATE PROCEDURE matricula_aluno
    @matricula INT,
    @curso CHAR(3),
    @materia CHAR(3),
    @professor INT,
    @perletivo INT
AS
BEGIN
    INSERT INTO MATRICULA (MATRICULA, CURSO, MATERIA, PROFESSOR, PERLETIVO)
    VALUES (@matricula, @curso, @materia, @professor, @perletivo)
END


CREATE OR ALTER PROCEDURE sp_CadastraNotas
	(
		@MATRICULA INT,
		@CURSO CHAR(3),
		@MATERIA CHAR(3),
		@PERLETIVO CHAR(4),
		@NOTA FLOAT,
		@FALTA INT,
		@BIMESTRE INT
	)
	AS
BEGIN

		IF @BIMESTRE = 1
		    BEGIN

                UPDATE MATRICULA
                SET N1 = @NOTA,
                    F1 = @FALTA,
                    TOTALPONTOS = @NOTA,
                    TOTALFALTAS = @FALTA,
                    MEDIA = @NOTA
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
		    END

        ELSE

        IF @BIMESTRE = 2
            BEGIN

                UPDATE MATRICULA
                SET N2 = @NOTA,
                    F2 = @FALTA,
                    TOTALPONTOS = @NOTA + N1,
                    TOTALFALTAS = @FALTA + F1,
                    MEDIA = (@NOTA + N1) / 2
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE

        IF @BIMESTRE = 3
            BEGIN

                UPDATE MATRICULA
                SET N3 = @NOTA,
                    F3 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2,
                    TOTALFALTAS = @FALTA + F1 + F2,
                    MEDIA = (@NOTA + N1 + N2) / 3
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE

        IF @BIMESTRE = 4
            BEGIN

                DECLARE @RESULTADO VARCHAR(50),
                        @FREQUENCIA FLOAT,
                        @MEDIAFINAL FLOAT,
                        @CARGAHORA INT

                SET @CARGAHORA = (
                    SELECT CARGAHORARIA FROM MATERIAS
                    WHERE       SIGLA = @MATERIA
                            AND CURSO = @CURSO)

                UPDATE MATRICULA
                SET N4 = @NOTA,
                    F4 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2 + N3,
                    TOTALFALTAS = @FALTA + F1 + F2 + F3,
                    MEDIA = (@NOTA + N1 + N2 + N3) / 4,
                    MEDIAFINAL = (@NOTA + N1 + N2 + N3) / 4,
                    PERCFREQ = 100 -( ((@FALTA + F1 + F2 + F3)*@CARGAHORA )/100)

                    --RESULTADO
                    ,RESULTADO =
                    CASE
                        WHEN ((@NOTA + N1 + N2 + N3) / 4) >= 7
                            AND (100 -( ((@FALTA + F1 + F2 + F3)*@CARGAHORA )/100))>=75
                        THEN 'APROVADO'

                        WHEN ((@NOTA + N1 + N2 + N3) / 4) >= 3
                            AND (100 -( ((@FALTA + F1 + F2 + F3)*@CARGAHORA )/100))>=75
                        THEN 'EXAME'

                        ELSE 'REPROVADO'

                    END

                        WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;


            END
        ELSE

        IF @BIMESTRE = 5

            BEGIN

                UPDATE MATRICULA
                SET NOTAEXAME = @NOTA,
                    MEDIAFINAL = (N1 + N2 + N3 + N4 + @NOTA) / 5,
                    RESULTADO =
                    CASE
                        WHEN ((N1 + N2 + N3 + N4 + @NOTA) / 5) >= 5
                        THEN 'APROVADO'
                        ELSE 'REPROVADO'

                    END

                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;


            END


		SELECT * FROM MATRICULA	WHERE MATRICULA = @MATRICULA
END
