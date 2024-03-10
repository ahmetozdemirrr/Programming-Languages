/************************** KNOWLEDGE BASE **************************/

/* PLACES */
place(admin_office).
place(cafeteria).
place(engineering_building).
place(library).
place(social_science_building).
place(lecture_hall_a).
place(institute_x).
place(institute_y).

/* 
	PERSONELS (12, 16 and 20 are the working hours of the workers, 
	if the cargo delivery time exceeds these hours, an error is given.)
*/ 
/* delivery_person(ID, CAPACITY, WORKING HOUR, CUREENT WORK, CURRENT LOCATION). */
delivery_person(courier1, 30, 12, o5, admin_office).
delivery_person(courier2, 40, 16, none, library).
delivery_person(courier3, 50, 20, none, institute_x).

/* OBJECTS */
/* object(ID, WEIGHT, PICK UP PLACE, DROP OF PLACE, URGENCY, ID OF PERSON) */
object(cargo1, 30, library, lecture_hall_a, low, none).
object(cargo2, 40, cafeteria, institute_x, medium, none).
object(cargo3, 50, social_science_building, admin_office, high, none).
object(cargo4, 60, engineering_building, institute_y, medium, none).
object(cargo5, 25, cafeteria, admin_office, high, dp1).

/* ROUTES */
route_direct(library, admin_office, 1).
route_direct(library, cafeteria, 5).
route_direct(library, social_science_building, 2).
route_direct(library, institute_y, 3).
route_direct(library, engineering_building, 5).
route_direct(institute_y, lecture_hall_a, 3).
route_direct(engineering_building, lecture_hall_a, 2).
route_direct(engineering_building, admin_office, 3).
route_direct(admin_office, cafeteria, 4).
route_direct(cafeteria, social_science_building, 2).
route_direct(social_science_building, institute_x, 8).

/************************* ~ Knowledge Base End ~ *************************/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rules %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/* dual-directionality feature */
dual(From, To, Distance) :-
	
	(	
		route_direct(From, To, Distance);
		route_direct(To, From, Distance)
	).

travel(From, To, Visited, Path, TotalDistance) :-

	dual(From, To, Distance),   /* if there is a direct line between the starting point and the end point.. */
	TotalDistance is Distance,  /* the total distance is the length of the line. */
	Path = [To | Visited]. 		/* add visited points to the list of routes travelled. */

travel(From, To, Visited, Path, TotalDistance) :-

	dual(From, Any, Distance),  /* if there is no other point between the two points, go from the starting point to any point */
	Any \== To, 				/* If To is the same as any selected point, it means that it has already been reached, so this is also incorrect. */
	\+member(Any, Visited), 	/* It should be a point that has not been visited before. */
	travel(Any, To, [Any | Visited], PathTail, RemainingDistance), /* recursively calls on itself to continue on the road */
	TotalDistance is Distance + RemainingDistance,
	Path = [Any | PathTail]. 	/* the visited points are added to this list (created for control purposes) */

route(From, To, Path, TotalDistance) :-

	travel(From, To, [From], Quer, TotalDistance),
	reverse(Quer, Path). /* Since the last path will be reversed, we return it to normal with reverse. */

are_there_delivery(Object_id, Delivery_person_id, Hour, Total_time) :-
	
	object(Object_id, Kg, Take, Put, _, Who),

	/* Is there 'none' in the Who variable? */
	(Who == none -> 
		
		(
			/* if Who is not in transit */
			delivery_person(Person_id, Capacity, Hour, none, Location),
			Delivery_person_id = Person_id,
			route(Location, Take, _, T1),
			route(Take, Put, _, T2),
			Kg =< Capacity,
			Total_time is T1 + T2
		); 
		
		/* else if Who is in transit */
		(
			nl,
            write('"'), write(Who), write('"'),
            write(' personell already transporting '), 
            write('"'), write(Object_id), write('"'), write('.'),
            nl, nl,
            fail /* fail statement is added to make this rule fail */
		)
	).

get_min_deliveries(Object_id, Delivery_person_id, Delivery_times, MinTime) :-
	
	/* 
		Delivery_times has more than one value in it (due to different paths),
	    Here we throw them all in a list and weed out the smallest one. 
	*/
	bagof(Total_time, are_there_delivery(Object_id, Delivery_person_id, Hour, Total_time), Delivery_times),
	min_list(Delivery_times, MinTime), /* we choose the least costly way */
	
	/* 
		the total time taken by the path chosen to take the least
	 	time should not exceed the working hours of the personnel 
	*/
	MinTime =< Hour. 

get_available_personel(Object_id, Delivery_person_id, Time) :-
	
	get_min_deliveries(Object_id, Delivery_person_id, _, Time).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
