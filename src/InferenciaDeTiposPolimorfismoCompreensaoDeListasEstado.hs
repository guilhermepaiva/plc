module InferenciaDeTiposPolimorfismoCompreensaoDeListasEstado where

import IntroducaoAProgramacaoFuncionalEHaskell
import DetalhesSobreListasERecursao

    
-- Polimorfismo, várias funções com o mesmo nome, assumindo várias formas
-- Diversos tipos de polimorfismo (de subtipo, ad hoc, paramétrico)
-- Inferência de tipos, entender o mecanismo com zipp

zipp :: [t] -> [u] -> [(t,u)]
zipp (a:as) (b:bs) = (a,b):zipp as bs
zipp _ _ = []

-- Comparar com um zipp sem os underlines
-- Exercitar mecanismo de inferência de tipos com reverse e ++, e depois com o procurar.
--
-- a ideia é tentar inferir o tipo da funcao. o ambiente haskell começa com a primeira equacao: conc [] l = l. 
-- por ai, ele ja descobre que essa função tem dois parâmetros. ele inicialmente registra que o tipo deve ser algo 
-- como conc :: x -> y -> z. indo adiante, olhando para o primeiro parâmetro, ele chega a conclusão que tem que ser 
-- uma lista. ai ele chega a conclusão parcial de que conc :: [a] -> y -> z. olhando o fato de que o parâmetro e resultado 
-- são os mesmos, ele chega a conc :: [a] -> y -> y. ai parte para a segunda equacao: conc (e:l) m = e:conc l m. 
-- como ele ja assumiu que o primeiro parâmetro é do tipo [a], a variável "e" tem que ser do tipo a, já que é
-- a cabeça da lista passada como primeiro parâmetro. se o primeiro parâmetro da segunda equação fosse 12, ele ja diria 
-- que a função não é bem tipada (uma equacao pedindo lista, a outra int, não teria como resolver). 
-- olhando para a direita do =, e vendo :, ele descobre que o resultado tem que ser lista. vendo mais ainda que a cabeça da 
-- lista resultante é "e", ele infere que o resultado é do tipo [a], já que antes a gente tinha concluído que "e" era do tipo a.
-- como o resultado é do tipo [a], e o segundo parâmetro é do mesmo tipo do resultado (ver raciocínio mais acima), ele infere
-- conc :: [a] -> [a] -> [a]. ele verifica que conc l m, que aparece no lado direito da equação, é do tipo [a],
-- que é justamente o tipo exigido pelo ":" à direita do =. Assim, ele termina e chega a conclusão que a função é
-- bem tipada. 

-- Exercícios

removeDups [] = []
removeDups (e:l) = if member e l then removeDups l else e:removeDups l

unique [] = []
unique [e] = [e]
unique (x:y:ys) | x == y = unique (y:ys)
		    | x /= y = x:unique (y:ys)


-- Ao invés de recursão, podemos usar compreensão de listas.

removerc n l = [(n1,s) | (n1,s) <- l, n1 /= n ]

-- Exercício: definir as outras funções (cadastrar e existe não fazem muito sentido).

procurarc n l = [(n1,s) | (n1,s) <- l, n == n1 ]

creditarc n v l = [ if (n == n1) then creditarConta (n1,s) v else (n1,s) | (n1,s) <- l]

creditarcc n v l = [ (n1,s) | (n1,s) <- l, n1 /= n ] ++ [ creditarConta (n1,s) v | (n1,s) <- l, n1 == n ]

-- de qualquer forma, esses dois creditar não são equivalentes ao primeiro quando 
-- a lista tem mais de um par com o mesmo número
-- equivalência comportamental, semântica: duas funções são equivalentes quando, para todas
-- as possíveis entradas, elas retornam o mesmo resultado. contrastar com igualdade sintática.

qsort [] = []
qsort (e:l) =    qsort [x | x <- l, x < e ]
              ++ [e]
              ++ qsort [x | x <- l, x >= e ]

-- qsort mais eficiente com split

split p [] = ([],[])
split p (x:xs) = if (x >= p) then (l,x:r) else (x:l,r)
			where (l,r) = split p xs

eqsort [] = []
eqsort (x:xs) =  eqsort l ++ [x] ++eqsort r
			where (l,r) = split x xs 


-- como simular estado com o banco...
-- onde a lista de contas ficaria armazenada? 
-- função que receberia lista infinita de strings correspondendo
-- a opções do menu e valores digitados, repassando o estado como parâmetro:

first (e:es) = e
second (e:es) = first es

sistema entrada = sist entrada []
sist [] estado = estado
sist ((comando,args):es) estado | comando == "cadastrar" =
                                  sist es (cadastrar (first args,0) estado)
                                | comando == "creditar" =
                                  sist es (creditar (first args) (read (second args)) estado)
                                | comando == "debitar" =
                                  sist es (debitar (first args) (read (second args)) estado)

-- Testando

est = sistema [("cadastrar",["1"]),("cadastrar",["2"]),("creditar",["1","55"]),
               ("creditar",["2","88"]),("debitar",["1","50"])]

-- e com concorrência?