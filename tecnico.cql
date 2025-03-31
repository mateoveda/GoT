// Archivo para hacer cosas

//cargar los Personajes
LOAD CSV WITH HEADERS FROM 'file:///got-s2-nodes.csv' AS row
CREATE (:Personaje {
    id: row.Id,
    name: row.Label
});

//comprobar
MATCH (p:Personaje) 
RETURN p.id, p.name;

//cargar los relaciones
LOAD CSV WITH HEADERS FROM 'file:///got-s2-edges.csv' AS row
MATCH (source:Personaje {id: row.Source}),
      (target:Personaje {id: row.Target})
CREATE (source)-[:HABLA_CON {conversaciones: toInteger(row.Weight), season: toInteger(row.Season)}]->(target);

//comprobar
MATCH (p:Personaje)-[r:HABLA_CON]->(p2:Personaje) 
RETURN p, r, p2;

//Cargar las casas:
LOAD CSV WITH HEADERS FROM 'file:///got-s2-casas.csv' AS row
CREATE (:Casa {
    id: toInteger(row.Id),
    name: row.Label
});

//comprobar
MATCH (c:Casa) 
RETURN c.id, c.name;

//cargar los relaciones
LOAD CSV WITH HEADERS FROM 'file:///got-s2-Personajes-casa.csv' AS row
MATCH (source:Personaje {id: row.IdPersonaje}),
      (target:Casa {name: row.House})
CREATE (source)-[:ES_LEAL_A]->(target);

//comprobar
MATCH (p:Personaje)-[r:ES_LEAL_A]->(c:Casa) 
RETURN p,r,c;

// PREGUNTAS ANÁLISIS BÁSICO (15 preguntas mínimo):

// 1. ¿Cómo es el esquema general del grafo?
CALL db.schema.visualization;

// 2. ¿Cuáles tipos de nodos existen y que atributos tienen?
CALL db.schema.nodeTypeProperties;

// 3. ¿Cuáles tipos de relaciones existen y que atributos tienen?
CALL db.schema.relTypeProperties;

// 4. ¿Cuántos Personajes existen?
MATCH (p:Personaje)
RETURN COUNT(p.id) AS Total_Personajes;

// 5. ¿Cuántas Casas existen?
MATCH (c:Casa)
RETURN COUNT(c.id) AS Total_Casas;

// 6. ¿Cuántas relaciones "HABLA_CON" existen?
MATCH (p)-[r:HABLA_CON]->(k)
RETURN COUNT(r) AS Total_HABLA_CON;

// 7. ¿Cuántas relaciones "ES_LEAL_A" existen?
MATCH (p)-[r:ES_LEAL_A]->(k)
RETURN COUNT(r) AS Total_ES_LEAL_A;

// 8. ¿Cuál es la suma toal de conversaciones?
MATCH (p)-[r:HABLA_CON]->(k)
RETURN SUM(r.conversaciones) AS Total_conversaciones;

// 9. ¿Cuál es el promedio de conversaciones?
MATCH (p)-[r:HABLA_CON]->(k)
RETURN AVG(r.conversaciones) AS Promedio_Conversaciones;

// 10. ¿Quiénes son los 5 personajes con más la mayor cantidad de conversaciones como atributo de HABLA_CON?
MATCH (p:Personaje)-[r:HABLA_CON]->(k:Personaje)
WITH p.id AS ID, COUNT(r) AS Cantidad_conversaciones
RETURN ID, Cantidad_conversaciones
ORDER BY Cantidad_conversaciones DESC
LIMIT 5;

// 11. ¿Cuáles son las casas que más gente leal tiene?
MATCH (p:Personaje)-[r:ES_LEAL_A]->(c:Casa)
WITH c.id AS ID, c.name AS nombre_casa, COUNT(r) AS Cantidad_Leales
RETURN ID, nombre_casa, Cantidad_Leales
ORDER BY Cantidad_Leales DESC
LIMIT 5;

// 12. ¿Cuántas Relaciones hay en Total?
MATCH (p)-[r]->(k)
RETURN COUNT(r) AS Total_relaciones;

// 13. ¿Cuál es el diámetro del grafo?
// En el PDF (se obtuvo con Gephi).

// 14. ¿Cuál es la densidad del grafo?
// En el PDF (se obtuvo con Gephi).

// 15. ¿Cuántas personas han hablado con un determinado personaje?
MATCH (p:Personaje{id:$neodash_personaje_id})-[r:HABLA_CON]->(p2:Personaje)
RETURN p.id AS ID, 
    p.name AS Nombre,
    COLLECT(p2.name) AS Lista_Personas_Habladas;

// 16. ¿Cuál es el promedio de conversaciones en una persona?
MATCH (p:Personaje{id:$neodash_personaje_id_2})-[r:HABLA_CON]->(p2:Personaje)
RETURN p.id AS ID, 
    p.name AS Nombre,
    AVG(r.conversaciones) AS Promedio_Conversaciones;

// 17. ¿Cuántas conversaciones tiene 'DAENERYS'?
MATCH (p:Personaje{id:'DAENERYS'})-[r:HABLA_CON]->(p2:Personaje)
RETURN p.id AS ID,
    p.name AS Personaje,
    SUM(r.conversaciones) AS Total_conversaciones;

// 18. ¿Cuál es el nodo con mayor número de relaciones?
MATCH (n)-[r]-(m)
RETURN n.id AS ID,
    COUNT(r) AS Total_relaciones
ORDER BY Total_relaciones DESC
LIMIT 1;

// 19. ¿Cuántos miembros tiene cada casa?
MATCH (p:Personaje)-[r:ES_LEAL_A]->(c:Casa)
WITH c.id AS ID_Casa,
    c.name AS Casa,
    COUNT(p) AS Total_Miembros
RETURN ID_Casa, Casa, Total_Miembros
ORDER BY Total_Miembros DESC;

// 20. ¿Cuántas personas no son leales a una casa en Juego de Tronos?
MATCH (p:Personaje)
WHERE NOT EXISTS { (p)-[:ES_LEAL_A]->(:Casa) }
RETURN COUNT(p) AS Personajes_sin_lealtad;

MATCH (p:Personaje)-[r:ES_LEAL_A]->(c:Casa)
RETURN COUNT(r);


//APLICACIÓN DE LOS ALGORITMOS DE CENTRALIDAD:

// DEGREE CENTRALITY
// PASO 1: Creamos el subgrafo
CALL gds.graph.project(
    'myGraphDEG',
    'Personaje',
    {HABLA_CON:
        {
            orientation: 'UNDIRECTED'
        }
    }
);

// Paso 2: Calculo la memoria necesaria:
CALL gds.degree.write.estimate(
    'myGraphDEG', {writeProperty: 'degree'})
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo:
CALL gds.degree.stream(
    'myGraphDEG'
)
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS id, gds.util.asNode(nodeId).name AS ciudad_Aeropuerto, score
ORDER BY score DESC, Aeropuerto ASC;

// Paso 4: Implementamos
CALL gds.degree.write('myGraphDEG', { writeProperty: 'degree' })
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimumScore, centralityDistribution.mean AS meanScore,
centralityDistribution.max AS maxScore, nodePropertiesWritten;


// CLOSENESS CENTRALITY
// PASO 1: Creamos el subgrafo
CALL gds.graph.project(
    'myGraphCC',
    'Personaje',
    'HABLA_CON'
);

// PASO 2: calcular la memoria
CALL gds.degree.write.estimate(
    'myGraphCC', { writeProperty: 'closenessCentrality' }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.pageRank.stream(
    'myGraphCC'
)
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS Name, score
ORDER BY score DESC, Name ASC;

// PASO 4: añadir el atributo
CALL gds.closeness.write('myGraphCC', {writeProperty: 'closenessCentrality'})
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimumScore,
        centralityDistribution.max AS maxScore,
        centralityDistribution.mean AS meanScore,
        nodePropertiesWritten;


// BETWEENNESS CENTRALITY:
// PASO 1:
CALL gds.graph.project(
    'myGraphBC',
    'Personaje',
    'HABLA_CON'
);

// PASO 2: calcular la memoria
CALL gds.betweenness.write.estimate(
    'myGraphBC', {writeProperty: 'betweennessCentrality'})
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.betweenness.stream('myGraphBC')
YEILD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS name, score
ORDER BY score DESC, name ASC;

// PASO 4: Escribimos el resultado como un atributo extra en cada nodo
CALL gds.betweenness.write('myGraphBC', {writeProperty: "betweennessCentrality"})
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimunScore,
        centralityDistribution.mean AS meanScore,
        centralityDistribution.max AS maxScore,
        nodePropertiesWritten;


// PAGERANK:
//PASO 1: Creamos el subgrafo:
CALL gds.graph.project(
    'myGraphPR',
    'Personaje',
    'HABLA_CON'
);

// PASO 2: calcular la memoria
// Aca estamos calculando el pageRank
CALL gds.pageRank.write.estimate(
    'myGraphPR', {
        writeProperty: 'pagerank', 
        maxIterations: 20,
        dampingFactor: 0.85}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.pageRank.stream(
    'myGraphPR'
)
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS Name, score
ORDER BY score DESC, Name ASC;

// PASO 4: añadir el atributo
CALL gds.pageRank.write(
    'myGraphPR',
    {
        maxIterations: 20,
        dampingFactor: 0.85,
        writeProperty: 'pagerank'
    }
)
YIELD nodePropertiesWritten, ranIterations;


// ARTICULATION POINTS:
// PASO 1: Creamos el subgrafo:
CALL gds.graph.project(
    'myGraphAP',
    'Personaje',
    {HABLA_CON:
        {
            orientation: 'UNDIRECTED'
        }
    }
);

// PASO 2: calcular la memoria
CALL gds.articulationPoints.stream.estimate(
    'myGraphAP', {writeProperty: 'articulationPoint'})
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.articulationPoints.stream('myGraphAP')
YEILD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS name, score
ORDER BY score DESC, name ASC;

// PASO 4: añadir el atributo (0 ó 1)
CALL gds.articulationPoints.write(
    'myGraphAP', 
    { 
        writeProperty: 'articulationPoint'
    }
)
YIELD articulationPointCount;


// BRIDGES:
// PASO 1: Creamos el subgrafo:
CALL gds.graph.project(
  'myGraphBridge',
  'Personaje',
  {HABLA_CON: {
      orientation: 'UNDIRECTED'  // Indica que las relaciones no tienen dirección
    }
  }
);

// PASO 2: calcular la memoria
CALL gds.bridges.stream.estimate(
    'myGraphBridge', {}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplico el algoritmo
CALL gds.bridges.stream('myGraphBridge')
YIELD from, to
RETURN gds.util.asNode(from).name AS fromName, 
       gds.util.asNode(to).name AS toName
ORDER BY fromName ASC, toName ASC;

// PASO 4: añadir el atributo
// En este caso el algoritmo Bridges nos señala relaciones que de romperse desconectarían partes de grafo. Por lo tanto no es algo que se guarde en un atributo (capaz sí en el de la relación)



// PREGUNTAS ANÁLISIS CENTRALIDAD (15 preguntas mínimo):
// 1. ¿Cuáles son los personajes con mayor Degree en el grafo?
MATCH (p:Personaje)
WITH p.id AS ID,
    p.name AS Nombre,
    p.degree AS Grado
ORDER BY Grado DESC, Nombre ASC
LIMIT 10
RETURN ID, Nombre, Grado;

// 2. ¿Cuáles son los Personajes con menor Degree en el grafo?
MATCH (p:Personaje)
WITH p.id AS ID,
    p.name AS Nombre,
    p.degree AS Grado
ORDER BY Grado ASC, Nombre ASC
LIMIT 10
RETURN ID, Nombre, Grado;

// 3. ¿Cuál es la distribución del Degree de los personajes en la red?
MATCH (p:Personaje)
WITH p.degree AS Grado, COUNT(p.degree) AS Total_Personajes_Grado
RETURN Grado, Total_Personajes_Grado
ORDER BY Grado DESC;

// 4. ¿Cuáles son aquellos personajes con un mayor Closeness Centrality?
MATCH (p:Personaje)
WITH p.id AS ID,
    p.name AS Nombre,
    p.closenessCentrality AS closenessCentrality
ORDER BY closenessCentrality DESC, Nombre ASC
LIMIT 10
RETURN ID, Nombre, closenessCentrality;

// 5. ¿Cuáles son aquellos personajes con un menor Closeness Centrality?
MATCH (p:Personaje)
WITH p.id AS ID,
    p.name AS Nombre,
    p.closenessCentrality AS closenessCentrality
ORDER BY closenessCentrality ASC, Nombre ASC
LIMIT 10
RETURN ID, Nombre, closenessCentrality;

// 6. ¿Cuáles son aquellos personajes con un alto Betweenness Centrality?
MATCH (p:Personaje)
WITH p.id AS ID,
    p.name AS Nombre,
    p.betweennessCentrality AS betweennessCentrality
ORDER BY betweennessCentrality DESC, Nombre ASC
LIMIT 10
RETURN ID, Nombre, betweennessCentrality;

// 7. ¿Cuáles son aquellos personajes con un alto Degree pero que no tienen un alto Betweenness Centrality?
MATCH (p:Personaje)
WITH p.id AS ID,
    p.name AS Nombre,
    p.degree AS Grado,
    p.betweennessCentrality AS betweennessCentrality
ORDER BY Grado DESC, Nombre ASC
LIMIT 20
ORDER BY betweennessCentrality ASC, Nombre ASC
LIMIT 10
RETURN ID, Nombre, Grado, betweennessCentrality;

// 8. ¿Cómo es la distribución del Betweenness centrality?
MATCH (p:Personaje)
WITH p.betweennessCentrality AS betweennessCentrality, COUNT(p.betweennessCentrality) AS Total_Personajes_Betweennes
RETURN betweennessCentrality, Total_Personajes_Betweennes
ORDER BY betweennessCentrality DESC;

// 9. ¿Cuáles son aquellos personajes con mayor PageRank?
MATCH (p:Personaje)
WITH p.id AS ID,
    p.name AS Nombre,
    p.pagerank AS pageRank
ORDER BY pageRank DESC, Nombre ASC
LIMIT 10
RETURN ID, Nombre, pageRank;

// 10. ¿Cuáles son aquellos personajes con un bajo Degree pero con un alto PageRank?
MATCH (p:Personaje)
WITH p.id AS ID,
    p.name AS Nombre,
    p.degree AS Grado,
    p.pagerank AS pageRank
ORDER BY pageRank DESC, Nombre ASC
LIMIT 20
ORDER BY Grado ASC, pageRank ASC
LIMIT 10
RETURN ID, Nombre, Grado, pageRank;

// 11. ¿Cuáles son aquellos personajes que tienen un alto Degree pero un bajo Page Rank?
MATCH (p:Personaje)
WITH p.id AS ID,
    p.name AS Nombre,
    p.degree AS Grado,
    p.pagerank AS pageRank
ORDER BY Grado DESC, Nombre ASC
LIMIT 20
ORDER BY pageRank ASC, Grado DESC
LIMIT 10
RETURN ID, Nombre, Grado, pageRank;

// 12. ¿Cuáles son los personajes con menor PageRank?
MATCH (p:Personaje)
WITH p.id AS ID,
    p.name AS Nombre,
    p.pageRank AS pageRank
ORDER BY pageRank ASC, Nombre ASC
LIMIT 10
RETURN ID, Nombre, pageRank;

// 13. Utilizando Articulation Point ¿Cuáles son aquellos personajes cuyo Articulation Point es True?
MATCH (p:Personaje)-[r:HABLA_CON]-(:Personaje)
WHERE p.articulationPoint = 1
WITH p.id AS ID,
    p.name AS Nombre,
    COUNT(r) AS Total_Relaciones
ORDER BY Total_Relaciones DESC
RETURN ID, Nombre, Total_Relaciones;

// 14. Utilizando Bridge ¿Cuáles son las relaciones frágiles en la red que, si se eliminan, fragmentarían la comunidad? 
CALL gds.graph.project(
  'myGraphBridge',
  'Personaje',
  {HABLA_CON: {
      orientation: 'UNDIRECTED'  // Indica que las relaciones no tienen dirección
    }
  }
);

CALL gds.bridges.stream('myGraphBridge')
YIELD from, to
RETURN gds.util.asNode(from).name AS fromName, 
       gds.util.asNode(to).name AS toName
ORDER BY fromName ASC, toName ASC;

// 15. ¿Cuál es la información de determinado personaje dado su ID?
MATCH (p:Personaje{id:3})
RETURN p.id AS ID,
    p.name AS Nombre,
    p.closenessCentrality AS ClosenessCentrality,
    p.betweennessCentrality AS BetweennessCentrality,
    p.pagerank AS pagerank,
    p.degree AS Degree,
    p.articulationPoint AS articulationPoint;

// 16. ¿A qué Casa pertenecen los 10 Personajes con mayor Degree?
MATCH (p:Personaje)-[r:ES_LEAL_A]->(c:Casa)
WITH p.id AS ID,
    p.name AS Nombre,
    p.degree AS Grado,
    c.name AS Casa
ORDER BY Grado DESC, Nombre ASC
LIMIT 10
RETURN COUNT(Casa) AS Total_Casa, Casa;

// 17. ¿A qué casa pertenecen los 10 personajes con mayor Closeness Centrality?
MATCH (p:Personaje)-[r:ES_LEAL_A]->(c:Casa)
WITH p.id AS ID,
    p.name AS Nombre,
    p.closenessCentrality AS ClosenessCentrality,
    c.name AS Casa
ORDER BY ClosenessCentrality DESC, Nombre ASC
LIMIT 10
RETURN COUNT(Casa) AS Total_Casa, Casa;

// 18. ¿A qué casa pertenecen los 10 personajes con mayor PageRank?
MATCH (p:Personaje)-[r:ES_LEAL_A]->(c:Casa)
WITH p.id AS ID,
    p.name AS Nombre,
    p.pagerank AS Pagerank,
    c.name AS Casa
ORDER BY Pagerank DESC, Nombre ASC
LIMIT 10
RETURN COUNT(Casa) AS Total_Casa, Casa;

// 19. ¿Qué personaje es el que tiene un alto Betweenness centrality entre distintas casas?
MATCH(c:Casa)<-[:ES_LEAL_A]-(p:Personaje)-[:HABLA_CON]-(p2:Personaje)-[:ES_LEAL_A]->(c2:Casa)
WHERE c.name <> c2.name
WITH p.id AS ID,
    p.betweennessCentrality AS betweennessCentrality,
    c.name AS Casa1,
    c2.name AS Casa2
ORDER BY betweennessCentrality DESC
RETURN ID, betweennessCentrality, Casa1, COLLECT(DISTINCT Casa2) AS Casas_Conectadas
LIMIT 10;

// 20. ¿Cuáles son los Personajes con menor PageRank por casa?
MATCH (c:Casa)<-[:ES_LEAL_A]-(p:Personaje)
WITH c.name AS Casa, p.name AS Personaje, p.pagerank AS PageRank
ORDER BY PageRank DESC
WITH Casa, COLLECT({Personaje: Personaje, PageRank: PageRank})[0] AS Mejor
RETURN Casa, Mejor.Personaje AS Personaje, Mejor.PageRank AS PageRank
ORDER BY PageRank DESC;



//APLICACIÓN DE LOS ALGORITMOS DE CENTRALIDAD:


// TRIANGLE COUNT
// PASO 1: Creamos el subgrafo:
CALL gds.graph.project(
    'myGraphTr',
    'Personaje',
    {HABLA_CON:
        {
            orientation: 'UNDIRECTED'
        }
    }
);

// PASO 2: calcular la memoria
CALL gds.triangleCount.write.estimate(
    'myGraphTr', {writeProperty: 'triangles'})
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.triangleCount.stream('myGraphTr')
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).name AS name, triangleCount
ORDER BY triangleCount DESC, name ASC;

// PASO 4: veamos que nodos pertenecen a un triangulo
CALL gds.triangleCount.write('myGraphTr', {
        writeProperty: 'triangles'
    }
)
YIELD globalTriangleCount, nodeCount;

// PASO 5: comprobar el atributo
MATCH (p:Personaje)
RETURN p.id AS ID,
    p.triangles as numero_de_triagulos
ORDER BY numero_de_triagulos DESC;


// LOCAL CLUSTERING COEFFICIENT

// PASO 1: subgrafo
CALL gds.graph.project(
  'myGraphCC',
  'Personaje',
  {HABLA_CON:
        {
            orientation: 'UNDIRECTED'
        }
    }
);

// PASO 2: calcular la memoria
CALL gds.localClusteringCoefficient.write.estimate('myGraphCC', {
  writeProperty: 'clusteringCoefficient'
})
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.localClusteringCoefficient.stream('myGraphCC')
YIELD nodeId, localClusteringCoefficient
RETURN gds.util.asNode(nodeId).name AS name, localClusteringCoefficient
ORDER BY localClusteringCoefficient DESC, name;

// PASO 4: escribir atributo
CALL gds.localClusteringCoefficient.write(
    'myGraphCC', 
    {
        writeProperty: 'clusteringCoefficient'
    }
)
YIELD nodeCount, nodePropertiesWritten;

// PASO 5: comprobar el atributo clusteringCoeficient con el mayor y sus vecinos
MATCH (p:Personaje)
ORDER BY p.clusteringCoefficient
MATCH (p:Personaje)-[r:HABLA_CON]-(v:Personaje)-[r2:HABLA_CON]-(v2:Personaje)
RETURN p, r, v, r2, v2;


// STRONGLY CONNECTED COMPONENTS
// PASO 1: subgrafo
CALL gds.graph.project(
  'myGraphSCC',
  'Personaje',
  {HABLA_CON:
        {
            Properties: 'conversaciones'
        }
    }
);

// PASO 2: calcular la memoria
CALL gds.scc.write.estimate('myGraphSCC', { writeProperty: 'communitySCC' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.scc.stream('myGraphSCC', {})
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).name AS Name, componentId AS Component
ORDER BY Component, Name DESC;

// PASO 4: escribir atributo
CALL gds.scc.write('myGraphSCC', {writeProperty: 'communitySCC'})
YIELD componentCount, componentDistribution;

// PASO 5: comprobar el atributo
MATCH (p:Personaje)
RETURN p.communitySCC as numero_de_SCC,
    COLLECT(p.name) AS Miembros
ORDER BY numero_de_SCC DESC;


// WEAKLY CONNECTED COMPONENTS
// PASO 1: subgrafo
CALL gds.graph.project(
  'myGraphWCC',
  'Personaje',
  {HABLA_CON:
        {
            orientation: 'UNDIRECTED',
            Properties: 'conversaciones'
        }
    }
);

// PASO 2: calcular la memoria
CALL gds.wcc.write.estimate('myGraphWCC', { writeProperty: 'communityWCC' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.wcc.stream('myGraphWCC')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).name AS name, componentId
ORDER BY componentId, name;

// PASO 4: escribir atributo
CALL gds.wcc.write('myGraphWCC', {writeProperty: 'communityWCC'})
YIELD componentCount, componentDistribution;

// PASO 5: comprobar el atributo
MATCH (p:Personaje)
RETURN p.communityWCC as numero_de_WCC,
    COLLECT(p.name) AS Miembros
ORDER BY numero_de_WCC DESC;


// LABEL PROPAGATION (General)
// PASO 1: subgrafo
CALL gds.graph.project(
    'myGraphLP',
    'Personaje',
    {HABLA_CON:
        {
            Properties: 'conversaciones'
        }
    }
);

// PASO 2: calcular la memoria
CALL gds.labelPropagation.write.estimate('myGraphLP', { writeProperty: 'labelPropagation' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.labelPropagation.stream('myGraphLP')
YIELD nodeId, communityId AS Community
RETURN gds.util.asNode(nodeId).name AS Name, Community
ORDER BY Community, Name;

// PASO 4: escribir atributo
CALL gds.labelPropagation.write('myGraphLP', {writeProperty: 'labelPropagation'})
YIELD communityCount, ranIterations, didConverge;

// PASO 5: comprobar el atributo
MATCH (p:Personaje)
RETURN p.labelPropagation as numero_de_comunidad,
    COLLECT(p.name) AS Miembros
ORDER BY numero_de_comunidad DESC;


// LABEL PROPAGATION (CERSEI)
// PASO 0: Añadimos una restricción iniciando con la semilla de CERSEI
MATCH (p:Personaje)
WHERE p.id = 'CERSEI'
SET p.comunidadInicialCERSEI = p.labelPropagation;

// PASO 1: subgrafo
CALL gds.graph.project(
    'myGraphCERSEI',
    'Personaje',
    {HABLA_CON:
        {orientation:'UNDIRECTED'}
    },
    {
        nodeProperties:['comunidadInicialCERSEI']
    }
);

// PASO 2: calcular la memoria
CALL gds.labelPropagation.write.estimate('myGraphCERSEI', { writeProperty: 'labelPropagationCERSEI' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.labelPropagation.stream('myGraphCERSEI')
YIELD nodeId, communityId AS Community
RETURN gds.util.asNode(nodeId).name AS Name, Community
ORDER BY Community, Name;

// PASO 4: escribir atributo
CALL gds.labelPropagation.write('myGraphCERSEI', {
    seedProperty: 'comunidadInicialCERSEI',
    writeProperty: 'labelPropagationCERSEI'
})
YIELD communityCount, ranIterations, didConverge;

// PASO 5: comprobar el atributo
MATCH (p:Personaje)
RETURN p.labelPropagationCERSEI as numero_de_comunidad,
    COLLECT(p.name) AS Miembros
ORDER BY numero_de_comunidad DESC;


// LABEL PROPAGATION (ROBB)
// PASO 0: Añadimos una restricción iniciando con la semilla de CERSEI
MATCH (p:Personaje)
WHERE p.id = 'ROBB'
SET p.comunidadInicialROBB = p.labelPropagation;

// PASO 1: subgrafo
CALL gds.graph.project(
    'myGraphROBB',
    'Personaje',
    {HABLA_CON:
        {orientation:'UNDIRECTED'}
    },
    {
        nodeProperties:['comunidadInicialROBB']
    }
);

// PASO 2: calcular la memoria
CALL gds.labelPropagation.write.estimate('myGraphROBB', { writeProperty: 'labelPropagationROBB' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.labelPropagation.stream('myGraphROBB')
YIELD nodeId, communityId AS Community
RETURN gds.util.asNode(nodeId).name AS Name, Community
ORDER BY Community, Name;

// PASO 4: escribir atributo
CALL gds.labelPropagation.write('myGraphROBB', {
    seedProperty: 'comunidadInicialROBB',
    writeProperty: 'labelPropagationROBB'
})
YIELD communityCount, ranIterations, didConverge;

// PASO 5: comprobar el atributo
MATCH (p:Personaje)
RETURN p.labelPropagationROBB as numero_de_comunidad,
    COLLECT(p.name) AS Miembros
ORDER BY numero_de_comunidad DESC;


// LABEL PROPAGATION (TYWIN)
// PASO 0: Añadimos una restricción iniciando con la semilla de CERSEI
MATCH (p:Personaje)
WHERE p.id = 'TYWIN'
SET p.comunidadInicialTYWIN = p.labelPropagation;

// PASO 1: subgrafo
CALL gds.graph.project(
    'myGraphTYWIN',
    'Personaje',
    {HABLA_CON:
        {orientation:'UNDIRECTED'}
    },
    {
        nodeProperties:['comunidadInicialTYWIN']
    }
);

// PASO 2: calcular la memoria
CALL gds.labelPropagation.write.estimate('myGraphTYWIN', { writeProperty: 'labelPropagationTYWIN' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.labelPropagation.stream('myGraphTYWIN')
YIELD nodeId, communityId AS Community
RETURN gds.util.asNode(nodeId).name AS Name, Community
ORDER BY Community, Name;

// PASO 4: escribir atributo
CALL gds.labelPropagation.write('myGraphTYWIN', {
    seedProperty: 'comunidadInicialTYWIN',
    writeProperty: 'labelPropagationTYWIN'
})
YIELD communityCount, ranIterations, didConverge;

// PASO 5: comprobar el atributo
MATCH (p:Personaje)
RETURN p.labelPropagationTYWIN as numero_de_comunidad,
    COLLECT(p.name) AS Miembros
ORDER BY numero_de_comunidad DESC;


// K-1 COLORING
// PASO 1: subgrafo
CALL gds.graph.project(
    'myGraphK1',
    'Personaje',
    {HABLA_CON:
        {orientation:'UNDIRECTED'}
    }
);

// PASO 2: calcular la memoria
CALL gds.k1coloring.write.estimate('myGraphK1', { writeProperty: 'k1color' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.k1coloring.stream('myGraphK1')
YIELD nodeId, color
RETURN gds.util.asNode(nodeId).name AS name, color
ORDER BY name;

// PASO 4: escribir atributo
CALL gds.k1coloring.write('myGraphK1', {writeProperty:'k1color'})
YIELD nodeCount, colorCount, ranIterations, didConverge;

// PASO 5: Sumarle +1 al color
MATCH (p:Personaje)
SET p.k1color = p.k1color + 1
RETURN p.k1color as numero_de_comunidad,
    COLLECT(p.name) AS Miembros
ORDER BY numero_de_comunidad DESC;

// PASO 6: comprobar el atributo
MATCH (p:Personaje)
RETURN p.k1color as numero_de_comunidad,
    COLLECT(p.name) AS Miembros
ORDER BY numero_de_comunidad DESC;


// LOUVAIN MODULARITY
// PASO 1: subgrafo
CALL gds.graph.project(
  'myGraphLM',
  'Personaje',
  {HABLA_CON:
        {
            orientation: 'UNDIRECTED',
            Properties: 'conversaciones'
        }
    }
);

// PASO 2: calcular la memoria
CALL gds.louvain.write.estimate('myGraphLM', { writeProperty: 'louvain' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.louvain.stream('myGraphLM')
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).name AS name, communityId
ORDER BY name ASC;

// PASO 4: escribir atributo
CALL gds.louvain.write('myGraphLM', {writeProperty: 'louvain'})
YIELD communityCount, modularity, modularities;

// PASO 5: comprobar el atributo
MATCH (p:Personaje)
RETURN p.louvain as numero_de_comunidad,
    COLLECT(p.name) AS Miembros
ORDER BY numero_de_comunidad DESC;


// MODULARITY METRIC
// PASO 1: subgrafo
CALL gds.graph.project(
    'myGraphMMetric',
    {
        Personaje: {
            properties: ['louvain']
        }
    },
    {
        HABLA_CON: {
            orientation: 'UNDIRECTED',
            properties: ['conversaciones']
        }
    }
);

// PASO 2: calcular la memoria
CALL gds.modularity.stats.estimate('myGraphMMetric', {
     communityProperty: 'labelPropagation',
     relationshipWeightProperty: 'conversaciones'
})
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.modularity.stream('myGraphMMetric', {
     communityProperty: 'louvain',
     relationshipWeightProperty: 'conversaciones'
})
YIELD communityId, modularity
RETURN communityId, modularity
ORDER BY modularity DESC;

// PASO 4: escribir atributo
CALL gds.modularity.stream('myGraphMMetric', {
     communityProperty: 'louvain',
     relationshipWeightProperty: 'conversaciones'
})
YIELD communityId, modularity

MATCH (p:Personaje)
WHERE p.louvain = communityId
SET p.modularityMetric = modularity;

// PASO 5: comprobamos
MATCH (p:Personaje)
RETURN p.modularityMetric AS MMetric, 
    COUNT(p) AS Cantidad_Miembros
ORDER BY MMetric;

// PREGUNTAS ANÁLISIS DE COMUNIDAD:

// 1.¿Qué personajes tienen la mayor cantidad de triángulos?
MATCH (p:Personaje)
RETURN p.id AS ID,
    p.triangles as numero_de_triagulos
ORDER BY numero_de_triagulos DESC
LIMIT 10;

// 2.¿Cuáles son las casas con más cantidad de triángulos en promedio?
MATCH (p:Personaje)-[r:ES_LEAL_A]->(c:Casa)
WITH c.name AS Casa,
    AVG(p.triangles) AS Promedio_Triangulos,
    SUM(p.triangles) AS Cantidad_Triangulos,
    COUNT(p.name) AS Cantidad_Miembros
RETURN Casa, Promedio_Triangulos, Cantidad_Triangulos, Cantidad_Miembros
ORDER BY Promedio_Triangulos DESC
LIMIT 10;

// 3.¿Qué personajes no tienen triángulos?
MATCH (p:Personaje)
WHERE p.triangles = 0
RETURN p.id AS ID,
    p.triangles as numero_de_triagulos
ORDER BY numero_de_triagulos DESC;

// 4.¿Cuáles son los personajes con mayor Clustering Coefficient?
MATCH (p:Personaje)
WHERE p.clusteringCoefficient = 1
RETURN p.id AS ID,
    p.degree AS Grado,
    p.clusteringCoefficient AS clusteringCoefficient
ORDER BY Grado DESC, ID ASC;

// 5.¿Qué Personajes tienen un alto Degree pero un bajo Clustering Coefficient?
MATCH (p:Personaje)
WITH p.id AS ID,
    p.degree AS Grado,
    p.clusteringCoefficient AS clusteringCoefficient
ORDER BY Grado DESC, ID ASC
LIMIT 20
ORDER BY clusteringCoefficient ASC, Grado DESC
LIMIT 10
RETURN ID, Grado, clusteringCoefficient;

// 6.Dar las comunidades SCC
MATCH (p:Personaje)
RETURN p.communitySCC, COUNT(*) AS sccSize
ORDER BY sccSize DESC;

// 7.¿Qué comunidades existen al aplicar WCC?
MATCH (p:Personaje)
RETURN p.communityWCC, COUNT(*) AS wccSize
ORDER BY wccSize DESC;

// 8.¿Cómo son las comunidades del Label Propagation sin semillas específicas?
MATCH (p:Personaje)
RETURN p.labelPropagation AS Comunidad, 
    COUNT(p) AS Cantidad_Miembros, 
    COLLECT(p.name) AS Miembros
ORDER BY Cantidad_Miembros DESC;

// 9.¿Cómo queda el grafo si CERSEI es semilla en Label Propagation?
MATCH (p:Personaje)
RETURN p.labelPropagationCERSEI, COUNT(*) AS lpcSize, COLLECT(p.name)
ORDER BY lpcSize DESC;

// 10.¿Cómo queda el grafo si ROBB es semilla en Label Propagation?
MATCH (p:Personaje)
RETURN p.labelPropagationROBB, COUNT(*) AS lprSize, COLLECT(p.name)
ORDER BY lprSize DESC;

// 11.¿Cómo queda el grafo si TYWIN es semilla en Label Propagation?
MATCH (p:Personaje)
RETURN p.labelPropagationTYWIN, COUNT(*) AS lptSize, COLLECT(p.name)
ORDER BY lptSize DESC;

// 12.¿Cuáles son las comunidades que existen con Louvain y quienes son los que las componen?
MATCH (p:Personaje) 
RETURN p.louvain, COUNT(*) AS lSize, COLLECT(p.name)
ORDER BY lSize DESC;

// 13.Dar las comunidades de Louvain que no tienen relación con ningún Stark y ningún Lannister
MATCH (o:Personaje)-[:HABLA_CON]-(p:Personaje)-[:ES_LEAL_A]->(c:Casa)
WITH o.louvain as louvain_Comunidad, 
    COLLECT(DISTINCT o.name) AS personajes, 
    COLLECT(DISTINCT c.name) AS casas
WHERE NONE(casa IN casas WHERE casa = "Stark" OR casa = "Lannister")   
RETURN louvain_Comunidad, personajes;

// 14.¿Cuáles son los personajes con más Closeness Centrality de cada comunidad de Louvain?
MATCH (p:Personaje)
WITH p.louvain AS louvain, 
    p.closenessCentrality AS closeCen,
    p.degree AS grado,
    p.name AS name
ORDER BY closeCen DESC, grado DESC
WITH louvain, collect(closeCen) as centralityList, collect(name) as nameList
RETURN louvain, nameList[0] as name, centralityList[0] as centralityAttr
ORDER BY louvain ASC;

// 15.Aplicando Metric Modularity ¿Qué comunidades tienen el menor Metric Modularity? y ¿Qué Personajes pertenecen a esas comunidades?
MATCH (p:Personaje)
WITH MIN(p.modularityMetric) AS MIN_MMetric
MATCH (p.Personaje)
WITH MIN_MMetric, 
    p.id AS ID,
    p.louvain AS ID_Comunidad,
    p.modularityMetric AS MMetric
RETURN ID, ID_Comunidad, MMetric
ORDER BY ID ASC;


// 16.¿Qué Personajes pertenecen a los últimos grupo de K1-Coloring?
MATCH (p:Personaje)
RETURN p.k1color AS numero_de_comunidad,
    COLLECT(p.name) AS Miembros
ORDER BY numero_de_comunidad DESC
LIMIT 5;

// 17.¿Existen Personajes dentro de alguna comunidad creada con Louvain tal que tengan un alto Betweenness Centrality?
MATCH (p:Personaje)
RETURN p.id AS ID,
    p.betweennessCentrality AS betweennessCentrality, 
    p.louvain AS louvain
ORDER BY betweennessCentrality DESC 
LIMIT 10;

// 18.Aplicando Louvain ¿Qué personajes con alto PageRank HABLA_CON otros personajes de distintas comunidades a la propia?
MATCH (p:Personaje)-[r:HABLA_CON]-(p2:Personaje)
WITH p.louvain AS louvain, 
     COLLECT(DISTINCT p2.louvain) AS Comunidades_Habladas, 
     MAX(p.pagerank) AS MaxPageRank
MATCH (p:Personaje)
WHERE p.pagerank = MaxPageRank AND p.louvain = louvain
RETURN p.id AS ID, MaxPageRank AS PageRank, louvain, Comunidades_Habladas
ORDER BY PageRank DESC;

// 19.¿Cuáles son los grupos formados con Louvain que tienen los personajes con menores Degrees?
MATCH (p:Personaje)
WITH p.degree as d, p.louvain as louvain, p.id AS ID
WHERE d = 1
RETURN louvain, COUNT(d) AS numeroDePersonajesConDegree1, COLLECT(ID) AS Personajes
ORDER BY numeroDePersonajesConDegree1 DESC;

// 20.¿Qué personajes agrupados con Louvain no pertenecen a una Casa específica?
MATCH (p:Personaje)
MATCH (follower:Personaje) -[r:ES_LEAL_A*..1]-> (c:Casa)
WITH p, collect(follower) as following
WHERE NONE(f in following WHERE f=p)
RETURN p.louvain as louvain, COLLECT(p.name) AS personajes
ORDER BY louvain DESC;




