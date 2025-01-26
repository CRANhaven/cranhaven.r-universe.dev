
pause <- function() {}

### load the example data

data(exampleData)
exampleData

pause()

### run fasjem algorithm to estimate two sparse precision matrices from example data

results = fasjem(X = exampleData, method = "fasjem-g", 0.1, 0.1, 0.1, 0.05, 10)
results
plot.fasjem(results)

pause()

plot.fasjem(results, type="share")

pause()

plot.fasjem(results, type="sub", subID=1)

pause()

plot.fasjem(results, type="neighbor", index=50)

pause()

### Output the top-10 hubs in each identified graph.

print("Output the top-10 hubs in each identified graph.")
hub = net.hubs(results)
hub

pause()

### Output the degrees of nodes in each identified graph.

print("Output the degrees of nodes in each identified graph.")
degree = net.degree(results)
degree

pause()

### Output the list of edges in each identified graph.

print("Output the list of edges in each identified graph.")
edges = net.edges(results)
edges

pause()

### Output the list of edges in each identified graph.

print("Output the list of edges in each identified graph.")
edges = net.edges(results)
edges

pause()

### Output the neighbors of 50th node in each identified graph.

print("Output the neighbors of 50th node in each identified graph.")
neighbors = net.neighbors(results,index=50)
neighbors

pause()
