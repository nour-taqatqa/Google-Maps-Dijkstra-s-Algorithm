#tests - plan route how many decimals does the distance hold? distance is a fraction right?
            ##2 routes that give the same distance - I need to make the ddecisin in function
            ##test for a destination that doesn't exist - done
            ##test for a destination taht is on the same position as the starting position - done
            ##different starting points to the same destinatino and checking result is different - done
            ##4 possible paths 
            ##intersection - how do I do that - not done 
            ## disconnected graph - not done 
                                     
test 'My first plan_route test': #one road only
   assert my_first_example().plan_route(0, 0, "Pierogi") == cons([0,0], cons([0,1], None))

def second_plan_route():
    return TripPlanner([[0.7,0, 0.1,0], [0.7,0, 0.5,-1], [0.5,-1, 0.1,0], [0.1,0, -2,-2]], #have multiple pois in the 
                       [[0.7,0, "pizza", "The Empty Bottle"],
                        [0.1,0, "pizza", "Pierogi"], #trying 2 destinatinos 
                        [0.1,0, "chicken ", "amore"],
                        [0.5,-1, "drinks", "poma"],
                        [0.5,-1, "chicken", "tonight"],
                        [-2,-2, "gifts", "high"]
                        ])   
                        
def four_path_plan_route(): #has stops 
    return TripPlanner([[0,0, 3,-0.5], [0,0, 1.5,-1], [0,0, -0.5,-1], [0,0, -3,-0.5], [0,-3, 3,-0.5],[0,-3, 1.5,-1],[0,-3, -0.5,-1],[0,-3, -3,-0.5], [-0.5,-1, 1.5,-1]], #have multiple pois in the 
                       [[0,0, "pizza", "The Empty Bottle"],
                        [0,-3, "gifts", "high"]
                        ]) 
def four_path_plan_route_second(): #this has a direct path without stops and 2 equal length paths 
    return TripPlanner([[0,0, 3,-0.5], [0,0, 1.5,-1], [0,0, -0.5,-1], [0,0, -3,-0.5], [0,-3, 3,-0.5],[0,-3, 1.5,-1],[0,-3, -0.5,-1],[0,-3, -3,-0.5], [0,0, 0,-3]], #have multiple pois in the 
                       [[0,0, "pizza", "The Empty Bottle"],
                        [0,-3, "gifts", "high"]
                        ])
def four_path_plan_route_second(): #2 equal paths only with many pois in each position
    return TripPlanner([[0,0, 3,-0.5], [0,0, -3,-0.5], [0,-3, 3,-0.5],[0,-3, -3,-0.5]], #have multiple pois in the 
                       [[0,0, "pizza", "The Empty Bottle"],
                        [0,-3, "gifts", "high"], #desired destination
                        [0,-3, "drinks", "lala"],
                        [0,-3, "drinks", "rest"],
                        [0,0, "pizza", "Pierogi"], 
                        [0,0, "chicken ", "amore"],
                        [3,-0.5, "drinks", "poma"],
                        [3,-0.5, "chicken", "tonight"],
                        [3,-0.5, "gifts", "paaa"],
                        [-3,-0.5, "pizza", "johns"],  
                        [-3,-0.5, "chicken ", "downtown"]                      
                        ]) 
                                   
test 'My plan_route-2-possible-roads-high':
   assert second_plan_route().plan_route(0.7, 0, "high") == cons([0.7,0] ,cons([0.1,0], cons([-2,-2], None))) #Cons.from_vec([[0.7,0], [0.1,0],[-2,-2]]) 
      
test 'My plan_route-2-possible-roads-high-2': #testing first test with a different starting point 
   assert second_plan_route().plan_route(0.5, -1, "high") ==  cons([0.5,-1], cons([0.1,0] ,cons([-2,-2], None))) #Cons.from_vec([[0.5,-1], [0.1,0],[-2,-2]])

test 'My plan_route-2-possible-roads-amore':
   assert second_plan_route().plan_route(0.5, -1, "amore") == cons([0.5,-1], cons([0.1,0], None))#Cons.from_vec([[0.7,0], [0.1,0],[-2,-2]]) 
   
test 'My plan_route-destination-same-source':
   assert second_plan_route().plan_route(-2, -2, "high") == cons([-2,-2], cons([-2,-2], None)) #do I repeat the destinatino or write it once?   

test 'My plan_route-destination-doesnt-exist':
   assert second_plan_route().plan_route(0, -1, "thankyou") == None#what should this return? don't know what reachable means

test 'My plan_route-4possible-paths': 
   assert four_path_plan_route().plan_route(0, 0, "high") == cons([0,0] ,cons([-0.5,-1], cons([0,-3], None)))
   assert four_path_plan_route().plan_route(0, 0, "thankyou") == cons(None) #test a destinatino that doesn't exist
   
test 'My plan_route-4possible-paths-2': 
   assert four_path_plan_route_second().plan_route(0, 0, "high") == cons([0,0], cons([0,-3], None))
   assert four_path_plan_route_second().plan_route(0, 0, "thankyou") == cons(None) #test a destinatino that doesn't exist  
   
test 'My plan_route-equal-length-roads': #equal length paths  
   assert four_path_plan_route_second().plan_route(0, 0, "high") == cons([0,0], cons([-3,-0.5], None))  #chose the left path, need to encode in function#

   
#tests: find nearby
        ## 4 pois with same category at same position (aka distance)
        ## try same destination with a different starting position
        ## try same destination and starting position but differnt n
                  
test 'My first find_nearby test':
    assert my_first_example().find_nearby(0, 0, "food", 1) == cons([0,1, "food", "Pierogi"], None)
    
test 'My first find_nearby test':
    assert my_first_example().find_nearby(0, 0, "food", 1) == cons([0,1, "food", "Pierogi"], None)
