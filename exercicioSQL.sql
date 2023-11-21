CREATE DATABASE ex9
GO
USE ex9
GO
CREATE TABLE editora (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
site			VARCHAR(40)		NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE autor (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
biografia		VARCHAR(100)	NOT NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE estoque (
codigo			INT				NOT NULL,
nome			VARCHAR(100)	NOT NULL	UNIQUE,
quantidade		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL	CHECK(valor > 0.00),
codEditora		INT				NOT NULL,
codAutor		INT				NOT NULL
PRIMARY KEY (codigo)
FOREIGN KEY (codEditora) REFERENCES editora (codigo),
FOREIGN KEY (codAutor) REFERENCES autor (codigo)
)
GO
CREATE TABLE compra (
codigo			INT				NOT NULL,
codEstoque		INT				NOT NULL,
qtdComprada		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL,
dataCompra		DATE			NOT NULL
PRIMARY KEY (codigo, codEstoque, dataCompra)
FOREIGN KEY (codEstoque) REFERENCES estoque (codigo)
)
GO
INSERT INTO editora VALUES
(1,'Pearson','www.pearson.com.br'),
(2,'Civilização Brasileira',NULL),
(3,'Makron Books','www.mbooks.com.br'),
(4,'LTC','www.ltceditora.com.br'),
(5,'Atual','www.atualeditora.com.br'),
(6,'Moderna','www.moderna.com.br')
GO
INSERT INTO autor VALUES
(101,'Andrew Tannenbaun','Desenvolvedor do Minix'),
(102,'Fernando Henrique Cardoso','Ex-Presidente do Brasil'),
(103,'Diva Marília Flemming','Professora adjunta da UFSC'),
(104,'David Halliday','Ph.D. da University of Pittsburgh'),
(105,'Alfredo Steinbruch','Professor de Matemática da UFRS e da PUCRS'),
(106,'Willian Roberto Cereja','Doutorado em Lingüística Aplicada e Estudos da Linguagem'),
(107,'William Stallings','Doutorado em Ciências da Computacão pelo MIT'),
(108,'Carlos Morimoto','Criador do Kurumin Linux')
GO
INSERT INTO estoque VALUES
(10001,'Sistemas Operacionais Modernos ',4,108.00,1,101),
(10002,'A Arte da Política',2,55.00,2,102),
(10003,'Calculo A',12,79.00,3,103),
(10004,'Fundamentos de Física I',26,68.00,4,104),
(10005,'Geometria Analítica',1,95.00,3,105),
(10006,'Gramática Reflexiva',10,49.00,5,106),
(10007,'Fundamentos de Física III',1,78.00,4,104),
(10008,'Calculo B',3,95.00,3,103)
GO
INSERT INTO compra VALUES
(15051,10003,2,158.00,'04/07/2021'),
(15051,10008,1,95.00,'04/07/2021'),
(15051,10004,1,68.00,'04/07/2021'),
(15051,10007,1,78.00,'04/07/2021'),
(15052,10006,1,49.00,'05/07/2021'),
(15052,10002,3,165.00,'05/07/2021'),
(15053,10001,1,108.00,'05/07/2021'),
(15054,10003,1,79.00,'06/08/2021'),
(15054,10008,1,95.00,'06/08/2021')

-- 1 
SELECT est.nome, est.valor, edi.nome, aut.nome
FROM estoque est, compra comp, autor aut, editora edi
WHERE comp.codEstoque = est.codigo
	AND est.codAutor = aut.codigo
	AND est.codEditora = edi.codigo

-- 2
SELECT est.nome, comp.qtdComprada, comp.valor
FROM compra comp, estoque est
WHERE comp.codEstoque = est.codigo
	AND comp.codigo = 15051

-- 3
SELECT est.nome,
	CASE WHEN(LEN(edi.site) > 10) THEN
	(SUBSTRING(edi.site, 5, LEN(edi.site)))
	ELSE edi.site END as siteEditora
FROM editora edi, estoque est
WHERE est.codEditora = edi.codigo
	AND edi.nome = 'Makron Books'

-- 4 
SELECT est.nome, aut.biografia 
FROM estoque est, autor aut
WHERE est.codAutor = aut.codigo
	AND aut.nome = 'David Halliday'

--  5
SELECT comp.codigo, comp.qtdComprada
FROM estoque est, compra comp
WHERE est.codigo = comp.codEstoque
	AND est.nome = 'Sistemas Operacionais Modernos '

-- 6
SELECT est.codigo, est.nome
FROM compra comp RIGHT OUTER JOIN estoque est
ON est.codigo = comp.codEstoque
WHERE comp.codEstoque IS NULL

-- 7
SELECT est.codigo, est.nome
FROM compra comp LEFT OUTER JOIN estoque est
ON comp.codEstoque = est.codigo
WHERE est.codigo IS NULL

-- 8
SELECT edi.nome, edi.site
FROM editora edi LEFT OUTER JOIN estoque est
on est.codEditora = edi.codigo
WHERE est.codEditora IS NULL

-- 9
SELECT aut.nome,
	CASE WHEN(aut.biografia LIKE 'Doutorado%') THEN
	('Ph.D.' + SUBSTRING(aut.biografia, 11, LEN(aut.biografia)))
	ELSE aut.biografia END AS autorBiografia
FROM estoque est RIGHT OUTER JOIN autor aut
ON est.codAutor = aut.codigo 
WHERE est.codigo IS NULL

-- 10
SELECT aut.nome, (MAX(est.valor)) as maiorValor
FROM estoque est, autor aut
WHERE est.codAutor = aut.codigo
GROUP BY aut.nome
ORDER BY (maiorValor) DESC

-- 11
SELECT comp.codigo, comp.qtdComprada, (SUM(comp.valor)) AS somaTotal
FROM compra comp
GROUP BY comp.codigo, comp.valor, comp.qtdComprada
ORDER BY (comp.codigo) ASC

-- 12
SELECT edi.nome, (AVG(est.valor)) AS mediaEstoque
FROM editora edi, estoque est
WHERE est.codEditora = edi.codigo
GROUP BY est.valor, edi.nome

-- 13
SELECT est.nome, est.quantidade, edi.nome,
	CASE WHEN(LEN(edi.site) > 10) THEN
	(SUBSTRING(edi.site, 5, LEN(edi.site)))
	ELSE edi.site END as siteEditora,

	CASE WHEN(est.quantidade < 5) THEN 'Produto em Ponto de Pedido'
	ELSE CASE WHEN(est.quantidade >= 5 AND est.quantidade <= 10) THEN 'Produto Acabando'
	ELSE 'Estoque Suficiente' END END as statusLivro
FROM estoque est, editora edi
WHERE est.codEditora = edi.codigo

-- 14
SELECT est.codigo, est.nome, aut.nome,
	CASE WHEN(edi.site IS NOT NULL) THEN
	(edi.nome + ' - ' + edi.site) ELSE edi.nome END AS infoEditora
FROM estoque est, autor aut, editora edi
WHERE est.codAutor = aut.codigo
	AND est.codEditora = edi.codigo

-- 15
SELECT comp.codigo, DATEDIFF(DAY, comp.dataCompra, GETDATE()) as diasCompra,
					DATEDIFF(MONTH, comp.dataCompra, GETDATE()) as mesesCompra
FROM compra comp

-- 16
SELECT comp.codigo, comp.qtdComprada * comp.valor AS somaTotal
FROM compra comp
WHERE (comp.qtdComprada * comp.valor) > 200.00