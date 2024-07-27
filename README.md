# Google-Maps-Dijkstra-s-Algorithm

**Goal**:
- To implement a trip planning API (Application Programming Interface) that provides routing and searching service

The trip planner will store map data representing three kinds of items andanswer three kinds of queries about them.

**Items**
- A position has a latitude and a longitude, both numbers.
- A road segment has two endpoints, both positions.
- A point-of-interest (POI) has a position, a category (a string), and a name
(a string). The name of a point-of-interest is unique across all points-ofinterest, but a category may be shared by multiple points-of-interest. Each
position can feature zero, one, or more POIs.

**Assumptions about segments and positions**
1. All roads are two-way roads.
2. The length of a road segment is the standard Euclidian distance between
its endpoints.
3. Points-of-interest can only be found at a road segment endpoint

### ADT's and Data Structures used:
**1) Dictionary 1**
- **Role**: position to number mapping. Converting raw positions into natural numbers such that they can become nodes in a graph
- **Data structure**: separate chaining hash table 
- **Why this data structure and not another** : The reason a hashtable ADT was used instead of a set ADT with a vector implementation is because a **“look up”** feature is needed in the context of finding what a certain position translates into a node. The two possible data structures for a hashtable are an association list and a hashtable. 2 factors go into deciding between the two. The first is whether there is a “fixed” number of elements to be stored. An association list allows for a growing number of elements as it implements a linked list, while a hashtable requires a hashing factor to be maintained and for more space to be made as more elements are being added. That makes an association list more superior in that manner, but for the TripPlanner, a fixed number of pois and roads is given, so either are fine for this factor. The other factor to consider is the time complexity of the look up. Other methods are needed like insertion and deletion but these happen only once in the instructor. Therefore, look up is the primary function to consider. An association list is O(n) whereas a hash table is O(1) on average. Although this “average” term is only given considering a good hashing factor and a big enough of a poi and road vector, it’s still a better time complexity than an association list. Considering the fixed number of elements and better time complexity, a hashtable was chosen throughout the entire program. 

**2) Dictionary 2**
- **Role**: number to position dictionary. This has the role of mapping back the position to numb dictionary back to numbers. This is useful for plan-route as, while working with the natural number representation of positions in the graph, a linked list of raw position needs to be constructed as output
- **Data structure**: a vector (using direct addressing) 
- **Why this data structure and not another**: mapping a numb to a string doesn’t takes a constant time as direct addressing is used (same concept as accessing indices, which is just a memory arrow that takes constant time). This is certainly the best option of a dictionary for mapping numbers to strings as constant time is the optimal time complexity. 

**3) Set**: 
- **Role**: representing all the roads in the trip planner, with information of the first road intersection, the second road intersection, and the distance between them, stored for later graph access 
- **Data structure**: vector 
- **Why this data structure and not another**: since keeping it simple is the way to go when in doubt, the other option other than a vector could’ve been a linked list. The primary goal of this set is to calculate the distance between the positions that are given in tuples in the roads vector and to store that with the positions. Both a linked list and a vector would take O(n) complexity for look up, however, since vectors allow for elements to be accessed via an index, it was easier to index the vector rather than cons elemented in a linked list. Therefore I used a vector to hold structs of Roads. 

**4) Weighted Undirected Graph**: 
- **Role**: represent positions as nodes and roads as edges 
- **Data structure**: adjacency matrix 
- **Why this data structure and not another****: For graphs, there is an option of an adjacency list and an adjacency matrix. Graphs have many functions associated with them. The ones to consider for the TripPlanner are set_edge and get_edge. For set edge, an **adjacency list** would have to look at the degree of the node we’re at (aka how many neighbors it has), and then add the new edge after it passes through the other neighbors in the “rib” for that node. That makes set edge O(n). An **adjacency matrix**, however, would just need to access a tuple index via direct addressing (will add a weight to the the entity at the position between these 2 nodes). This would take O(1). Therefore, in terms of time complexity, set edge tells us to use a matrix

Additionally, in terms of the get_edge function, a similar logic will have to be applied. To get an edge with an adjacency list, the computer has to look through every single node the node we’re at has edges with, and then access the weight stored at that edge and return it. Meanwhile an adjacency matrix would only need direct addressing (by accessing a tuple index) to return the weight at that edge, as a matrix has its nodes and edges laid out in a row, column format. That makes an adjacency list O(degree of node) and makes a matrix have constant time, for get_edge as well. Space complexity is compromised with a matrix but that isn’t the interest of our project implementation. 

A matrix was implemented for those reasons.

**5) Dictionary 3**: 
- **Role**: maps category to position. Each key will be a different category and the value for this key is a linked list of positions for which the category is present. This was used to return the positions for locate_all.   
- **Data structure**: separate chaining hash table 
- **Why this data structure and not another**: same reasoning as in dictionary 1, except that keys aren't positions here and th

**6) Dictionary 4**:
- **Role**: position to POI - used for find_nearby. Maps the position to all the pois present at that position, regardless of the category. It was used to make the process of returning a linked list of poi’s at each position easier 
- **Data structure**: separate chaining hash table 
- **Why this data structure and not another**:  same reasoning as in dictionary 1



**7) Dictionary 5**:
- **Role**: name to position - used for plan-foute: we’re given a destination name and have to return raw positions for it
- **Data structure**: separate chaining hash table 
- **Why this data structure and not another**: same reasoning as in dictionary 1, in addition to considering the time complexity it would need to loop through the positions, in the case that I didn’t have a hashtable. If I didn’t use a hash table, I would have to loop through all the positions until the position of the destination name is reached, for which the destination name has to be associated somehow with the positions I’m considering and looping through. Looping through the positions is O(n). An alternative to looping through the positions was to create a dictionary that would make the process of look up O(1) on average. 

**8) Priority queue 1**:
- **Role**: dijkstra implementation - deciding on what node to visit next based on the smallest weight
- **Data structure**: binary heap 
- **Why this data structure and not another**: Can have 3 possible implementations for PQ. The first is a sorted vector. This would have O(n) insertion and O(1) remove_min time complexity (have to insert in the correct sorted position, so O(n)). An unsorted vector would have same time complexities but flipped, O(1) for insertion and O(n) for remove_min. A binary heap was chosen instead of these 2 because in the worst case, both inserting and removing make changes along a path between one leaf and the root, which would be as expensive as the height of the tree which is O (log n). That would be O (log n) for both insertion and remove_min, which is better than having one of the 2 functions be O (n)

**9) Priority queue 2**:
- **Role**: find nearby - sorting the distances from smallest to largest in order to return n pois with the positions with the smallest distances from source node
- **Data structure**:binary heap 
- **Why this data structure and not another**: same reasoning as Priority queue 1 above
