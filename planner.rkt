#lang dssl2

# Final project: Trip Planner

import cons
import 'project-lib/dictionaries.rkt'
#import 'project-lib/project-lib/compiled/dictionaries.rkt' #is this how we import?
import 'project-lib/graph.rkt'
import 'project-lib/binheap.rkt'
#import 'project-lib/project-lib/compiled/binheap.rkt'
import sbox_hash

let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]

### Basic Types ###

#  - Latitudes and longitudes are numbers:
let Lat?  = num?
let Lon?  = num?

#  - Point-of-interest categories and names are strings:
let Cat?  = str?
let Name? = str?

### Raw Item Types ###

#  - Raw positions are 2-element vectors with a latitude and a longitude
let RawPos? = TupC[Lat?, Lon?]

#  - Raw road segments are 4-element vectors with the latitude and
#    longitude of their first endpoint, then the latitude and longitude
#    of their second endpoint
let RawSeg? = TupC[Lat?, Lon?, Lat?, Lon?] ##

#  - Raw points-of-interest are 4-element vectors with a latitude, a
#    longitude, a point-of-interest category, and a name
let RawPOI? = TupC[Lat?, Lon?, Cat?, Name?]

### Contract Helpers ###

# ListC[T] is a list of `T`s (linear time):
let ListC = Cons.ListC
# List of unspecified element type (constant time):
let List? = Cons.list?


interface TRIP_PLANNER:

    # Returns the positions of all the points-of-interest that belong to
    # the given category.
    def locate_all(
            self,
            dst_cat:  Cat?           # point-of-interest category
        )   ->        ListC[RawPos?] # positions of the POIs

    # Returns the shortest route, if any, from the given source position
    # to the point-of-interest with the given name.
    def plan_route(
            self,
            src_lat:  Lat?,          # starting latitude
            src_lon:  Lon?,          # starting longitude
            dst_name: Name?          # name of goal
        )   ->        ListC[RawPos?] # path to goal

    # Finds no more than `n` points-of-interest of the given category
    # nearest to the source position.
    def find_nearby(
            self,
            src_lat:  Lat?,          # starting latitude
            src_lon:  Lon?,          # starting longitude
            dst_cat:  Cat?,          # point-of-interest category
            n:        nat?           # maximum number of results
        )   ->        ListC[RawPOI?] # list of nearby POIs

struct Road:
    let Position1
    let Position2
    let distance

struct Position: #I'm not really using it now
    let lat
    let long
    
struct POI: #
    let lat
    let long
    let category
    let name #-- this is capital to represtn fact that it's a struct. correct?

struct node: #for binary heap 
    let vertex
    let weight
    
struct heap_vertex: #for find nearby
    let vertex
    let distance

class TripPlanner (TRIP_PLANNER):
    let all_roads 
    let pois
    let position_to_num_dict
    let numb_to_positions_dict
    let road_graph
    let name_to_position_dict
    let position_to_poi
    
    def __init__(self, roads, pois):

        let poi_lis = None     
        self.position_to_num_dict= HashTable( roads.len() * 2 , make_sbox_hash()) 
        self.numb_to_positions_dict= [None; roads.len() * 2] 
        let counter =0
        #let i_counter= 0
        for i, road in roads:
            let lat1 = road[0]
            let long1 = road[1]
            let lat2 = road[2]
            let long2 = road[3]
            let position1 = [lat1,long1]#Position (lat1, long1) #[lat1,long1] #Position (lat1,long1)
            let position2= [lat2,long2]#Position (lat2, long2)
            #let position1_raw = [position1.lat, position1.long]
            #let position2_raw = [position2.lat, position2.long]
            if  self.position_to_num_dict.mem?(position1) == False:
                self.position_to_num_dict.put(position1, counter) #this was i
                self.numb_to_positions_dict.put(counter, position1)
                counter = counter +1
                #i_counter = i_counter +1
            if  self.position_to_num_dict.mem?(position2) == False:
                self.position_to_num_dict.put(position2, counter) #this was i 
                self.numb_to_positions_dict.put(counter, position2)
                counter = counter +1
                #i_counter = i_counter +1

        #println("printing length or roads vector : %p", roads.len())
        #println("printing length of dictionary : %p", self.position_to_num_dict.len())       
        self.all_roads = [None; roads.len()] # use self. for this ? pm said don't need to intilize it yet, why? - she aslo said no need to intitalize it 
        for i, road in roads:
            let lat1 = road[0]
            let long1 = road[1]
            let lat2 = road[2]
            let long2 = road[3]
            let position1 = [lat1,long1]#Position (lat1,long1)
            let position2= [lat2,long2] #Position (lat2, long2)
            let distance  =  ((lat1-lat2)*(lat1-lat2) + (long1 - long2)*(long1 - long2)).sqrt() #correct format?
            self.all_roads[i] = Road(position1, position2, distance)

        self.road_graph= WUGraph(counter)#self.position_to_num_dict.len()) #max num of nodes is num edges squared - she said length is fine 
        for i in self.all_roads:
            #println("printing iiiii : %p", i)
            let position1 = self.position_to_num_dict.get(i.Position1) #is this correct?
            let position2 = self.position_to_num_dict.get(i.Position2)
            let distance  = i.distance
            self.road_graph.set_edge(position1, position2,distance)
            #println("printing all edges : %p", self.road_graph.get_all_edges())
        #for i in range(self.all_roads):
         #   println("printing iiiii : %p", i)
          #  let position1 = self.position_to_num_dict.get(self.all_roads[i].Position1) #is this correct?
           # let position2 = self.position_to_num_dict.get(self.all_roads[i].Position2)
            #let distance  = self.all_roads[i].distance
            #self.road_graph.set_edge(position1, position2,distance)
            
        #println("here")
        self.pois=HashTable(  pois.len() , make_sbox_hash()) #this deals with duplicates? pois dont' have duplicates : , replacing the key’sprevious value if already present.
        #println("printing length: %p", pois.len()) #don't know if the size of this is an issue
        let value  #value is a linked list 
        let updated_value
        let new_value
        let new_node
        let current
        for poi in pois: #category to poistion dict: positio
            let flag = False
            let category = poi[2]
            let lat = poi[0]
            let long = poi[1]
            let name = poi[3]
            let position = Position(lat,long) #a tuple instead of a cons?
            let raw_position = [position.lat, position.long]
            if self.pois.mem?(category) == True:
                value = self.pois.get(category) #linked list of positions
                #println("printing value beofre: %p", value)
                current = value 
                while current is not None:
                    if raw_position == current.data:
                        flag = True
                        #println("is breaking ")
                        break
                    else:
                        current = current.next
                if flag == False:
                    #println("printing current beofre: %p", current)
                    #println("printing value after: %p", value)
                    new_value = cons(raw_position, value)
                    self.pois.put(category, new_value)
            else:
                #println("adding new")
                self.pois.put(category, cons(raw_position,None)) #value)

                               
        self.position_to_poi =  HashTable(  counter , make_sbox_hash()) #this had a size of pois.len()
        let poi_list = None 
        for poi in pois:
            let category = poi[2]
            let lat = poi[0]
            let long = poi[1]
            let name = poi[3]
            let position = [lat,long] #a tuple instead of a cons?
            if self.position_to_poi.mem?(position) == True:      #would mem work on a tuple?-------
                #poi = [lat, long, category, name] #POI(lat, long, category, name) #I'm making it a struct instead of a vector
                poi_list = self.position_to_poi.get(position) 
                poi_list = cons(poi, poi_list)
                self.position_to_poi.put(position, poi_list)
            else:
                self.position_to_poi.put(position, cons(poi, None))
                     
               
        self.name_to_position_dict=HashTable( pois.len() , make_sbox_hash()) #this deals with duplicates? pois dont' have duplicates : , replacing the key’sprevious value if already present.
        for poi in pois: #if name exist, if it doesn't return None - he didn't get why I was doing hashtable
            let name = poi[3] #this is for my plan route 
            let category = poi[2]
            let lat = poi[0]
            let long = poi[1]
            let position = [lat,long] #a tuple instead of a cons?
            self.name_to_position_dict.put(name, position)
               
    def locate_all (self, dst_cat): # positions of the POIs -- no duplicates allowed - linked list of raw positino - should I create dict?
        if self.pois.mem?(dst_cat)== True:
            return self.pois.get(dst_cat)
        else:
            return None ####test 3/4 categories in same position
        #hashtable solution -- what are locate all's edge cases?
        #for index, i in self.pois: #want an association list 
        #all_positions = self.pois.get(dst_cat)
        #for i in all_positions: #can't loop through a dict
        #    position = self.pois.get(dst_cat)

        #fr i in 
        #for loop solution -- should dealwith duplicates
        #let positions = None #this is linked list 
        #for index, i in self.pois:
        #    if i.category =  dst_cat:
        #        let position_lat = i.Position.latitude
        #        let position_long = i.Position.longtitude
        #        position = Position(position_lat,position_long) ##convert to brackets 
        #        positions = cons(position, positions) ##is this how we do it?
        #return positions
        
    def dijkstra (self, source_node): #returns predecessors first then distances vector 
        let finished_nodes = [False; self.road_graph.n_vertices()] #true or false 
        let to_do_nodes = BinHeap(self.road_graph.n_vertices() * self.road_graph.n_vertices(), λ x, y: x.weight < y.weight) #create a struct and comare feilds of structs -- size is correct
        let predecessors=[None; self.road_graph.n_vertices()]
        predecessors[source_node] = None #is this correct?            
        let distances_vector = [inf; self.road_graph.n_vertices()  * self.road_graph.n_vertices()] #are all 3 of them same length? how to intialize infinity?      
        distances_vector[source_node] = 0
       
        to_do_nodes.insert(node(source_node, 0))  #does the source node have to be the first elemnt in the distanes vector? I put source node instead of zero becuase source_node is the actual number of the staring node
            
        let smallest_node  #is this correct? isn't that too many variables to declare outside?
        let adjacent_nodes
        let weight #no need for a none 
        let adjacent_node
            
        while to_do_nodes.len() != 0:#None: #is this condition correct? can teh weight be none? #this will be O(n^2)-------------------(O E log E)
            #println("plan route")
            #check if find min is none 
            smallest_node = to_do_nodes.find_min().vertex #this is hte node with the smallest weight
            #println("printing smallest node before: %p", smallest_node)
            to_do_nodes.remove_min()
                #current_node = smallest_node -- I commneted this out 
            adjacent_nodes = self.road_graph.get_adjacent(smallest_node) #changed this to current node  
            #println("printing adjacent nodes : %p", adjacent_nodes)
                        
            if finished_nodes[smallest_node] == False :
                finished_nodes[smallest_node] = True 
             #   println("Hwllo")
                while adjacent_nodes != None: #adjacent_nodes: #wouldn't this increase my complexiyt a lot?
                    adjacent_node = adjacent_nodes.data
                    weight = self.road_graph.get_edge(smallest_node, adjacent_node) #this was current node, and .data
                    if distances_vector[smallest_node] +  weight < distances_vector[adjacent_node]:#what should the index be? #total path - how do I indicate that, my dist vector is empty 
                        distances_vector[adjacent_node] = distances_vector[smallest_node] +  weight
                        #println("printing smallest node ------------------: %p", smallest_node)
                        predecessors[adjacent_node] = smallest_node #why do we not mark node as done?
                        to_do_nodes.insert(node(adjacent_node, distances_vector[adjacent_node] )) 
                    adjacent_nodes= adjacent_nodes.next
        return [predecessors, distances_vector]
 
  
#test, locate all
        #test if pois were all of hte same category in all positinos 
        #test if pois were all of hte same category in one position only and the rest had other pois - no duplicates for the ones in same position
        #test if there is only 1 poi in each catagory at each poistion -- kind of included that in the 
        #test if there are no pois at any position - should return an empty linked list - included in the second test - food 
        #test if there are pois of same category at one position and there are no pois in all other position - linked list should have 1 item only
#helper: lon ,lat -- return dsitances and predecessors 
    def plan_route(self,src_lat:  Lat?, src_lon:  Lon?, dst_name: Name?): # ->        ListC[RawPos?]
                 
        let linked_list
        let current_node
        let position 
        if self.name_to_position_dict.mem?(dst_name) == True: #------------------------------
            let destination_position=self.name_to_position_dict.get(dst_name) #this has not to be none? 
           # println("printing position: %p", destination_position)
            let destination_node= self.position_to_num_dict.get(destination_position) #this is the node number
            #println("printing destination node: %p", destination_node)
            #println("printing lat, long of source: %p", [src_lat,src_lon])
            let source_node= self.position_to_num_dict.get([src_lat,src_lon]) #this is the node number
            #println("printing source_node: %p", source_node)
         
            let result = self.dijkstra(source_node)
            let predecessors = result[0]
            let distances_vector = result[1]
           
            #println("later")
            #println("printing n_vertices: %p", self.road_graph.n_vertices())
            #println("printing predecessors: %p",predecessors)
 
            let curr =destination_node
            let linked_list = None
            let predecessor_position
            #println("ooooooooo")
            #println("printing curr before: %p",curr)
            while curr != None: #this was predecessor ---- I'm indexing none somewhere here: is my vecotor filled with empty none?
             #   println("printing dest curr after: %p", curr)
                predecessor_position = self.numb_to_positions_dict.get(curr)
                linked_list = cons(predecessor_position, linked_list)#shortest_path_linked_list)
                curr = predecessors[curr]
              #  println("printing curr after: %p", curr)
            #let source_node_position = self.numb_to_positions_dict.get(source_node)
            #linked_list = cons(source_node_position,linked_list)
            return linked_list 
           # println("printing linked list after: %p", linked_list)
        else:
            #println("other case")
            return None #------------------------ should I be returnig none ?      

                        
    def find_nearby (self, src_lat, src_lon, dst_cat, n) : #->        ListC[RawPOI?] -------- what is desired complexity? -- cubed might be ecessive -- if it takes more than 5 seconds, try to optimize it
        
        let smallest_distance
        if self.pois.mem?(dst_cat) == True:
            #println("entering loop")
            let source_node = self.position_to_num_dict.get([src_lat, src_lon ])
            let distances = self.dijkstra(source_node)[1]#[None;  self.road_graph.n_vertices() * self.road_graph.n_vertices()] #array
            #println("printing distances: %p",distances)
            let binheap = BinHeap(self.road_graph.n_vertices() * self.road_graph.n_vertices(), λ x, y: x.distance < y.distance) #create a struct and comare feilds of structs -- size is correct
            let positions_of_category = self.locate_all(dst_cat) #linked list
            #println("printing locate all result: %p",positions_of_category)
            let curr = positions_of_category
            while curr != None:
             #   println("find nearby")                
                let node_id = self.position_to_num_dict.get(curr.data)
                #let connected_nodes_to_source_node = self.road_graph.get_edge
                #if self.road_graph.get_edge(source_node, ) #get all edge, only add node to binary heap if it's connected to source node
                let distance = distances[node_id]
                if distance < inf:
                    binheap.insert(heap_vertex(node_id, distance))
                curr = curr.next #is this correct?
                #println("printing locate all result: %p",positions_of_category)
              #  println("hereeeeee")
            let smallest_distances = [None; binheap.len()] #n # a vector of nodes of smallest distances from source node : changed this from binheap.len to n
            if n <= binheap.len():
               # println("binheappppp")
                for i in range(n):
                    smallest_distance = binheap.find_min().vertex                    
                    smallest_distances[i] =smallest_distance
                    binheap.remove_min()
            else:
                for i in range(binheap.len()):
                    #println("entering other loop")
                    smallest_distance = binheap.find_min().vertex
                    smallest_distances[i] =smallest_distance #these are nodes of smallest distances 
                    binheap.remove_min()
                
            let poi_final_list = None #this is the poi linked list 
            let poi_count= 0
            #let counter
            let poi_info #make a counter nad counter should be n
            #println("printing smallest distances vector : %p",smallest_distances)
            for i in range(smallest_distances.len()):
                #if poi_count >= n:
                #    break
                #println("entering final list")
                if smallest_distances[i] != None:
                    #println("printing smallest distances i: %p",smallest_distances[i])
                    #println("printing smallest_distances.len() %p",smallest_distances.len())
                    #println("inner loop")
                    let position = self.numb_to_positions_dict[smallest_distances[i]] #this is O(n)
                    #println("printing position: %p",position)
                    let poi = self.position_to_poi.get (position) #this is a linked list --swhat does this return if have multiple pois in same position
                    #println("printing list of pois: %p",poi)
                    while poi != None:
                     #   println("find nearby ----------")
                        if poi.data[2] == dst_cat:
                            if poi_count == n:
                      #          println("breaking")
                                break
                            else:
                                poi_info = poi.data
                       #         println("data")
                                poi_final_list = cons (poi_info, poi_final_list)
                        #        println("final list ")
                                poi= poi.next #is this correct
                                poi_count = i +1

                        else:
                            #println("entering else case ")
                            poi = poi.next
                            #i = i +1
            return poi_final_list 
        else: #retun none if the destinatino doens't exist 
            return None                     
#######################################################

