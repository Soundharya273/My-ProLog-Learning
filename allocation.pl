round_up(X, Y) :- Y is ceiling(X).
minimum(A, B, A) :- A =< B, !.
minimum(_, B, B).

calculate_plan(D, Output) :-
    priority_score(D, Score), priority_level(Score, Level),
    get_dict(foodRequired,D,FoodReq), get_dict(availableFood,D,FoodAvail),
    get_dict(medicineRequired,D,MedReq), get_dict(availableMedicine,D,MedAvail),
    get_dict(rescueRequired,D,TeamReq), get_dict(availableTeams,D,TeamAvail),
    get_dict(urgency,D,U), get_dict(population,D,Population), get_dict(criticalPatients,D,Critical),
    get_dict(buildingDamage,D,Damage), get_dict(roadStatus,D,Road),
    get_dict(distance,D,Distance), get_dict(weatherSeverity,D,Weather),
    get_dict(communicationStatus,D,Communication), get_dict(shelterCapacity,D,Shelter),
    get_dict(maxDeliveryTime,D,MaxTime),
    damage_value(Damage, DamagePoints), severity_value(Weather, WeatherPoints),
    cap(Population,10000,PopCap), PopBonus is round(PopCap/1000),
    cap(Critical,1000,CritCap), MedicalBonus is round(CritCap/100),
    FoodUpper is min(FoodReq, FoodAvail), MedUpper is min(MedReq, MedAvail), TeamUpper is min(TeamReq, TeamAvail),
    FoodFloor0 is min(FoodReq, max(0, round(FoodReq * (0.50 + U*0.08 + Score/1000 + PopBonus/100)))),
    MedFloor0 is min(MedReq, max(0, round(MedReq * (0.55 + U*0.07 + MedicalBonus/100 + Score/1000)))),
    TeamFloor0 is min(TeamReq, max(0, round(TeamReq * (0.50 + U*0.08 + DamagePoints/100 + Score/1000)))),
    FoodFloor is min(FoodFloor0, FoodUpper), MedFloor is min(MedFloor0, MedUpper), TeamFloor is min(TeamFloor0, TeamUpper),
    FoodAllocated in 0..FoodUpper, MedicineAllocated in 0..MedUpper, TeamsAllocated in 0..TeamUpper,
    FoodAllocated #>= FoodFloor, MedicineAllocated #>= MedFloor, TeamsAllocated #>= TeamFloor,
    labeling([max(FoodAllocated+MedicineAllocated+TeamsAllocated)], [FoodAllocated,MedicineAllocated,TeamsAllocated]),
    FoodShortage is FoodReq-FoodAllocated, MedicineShortage is MedReq-MedicineAllocated, TeamShortage is TeamReq-TeamsAllocated,
    delivery_time(Distance,Road,Weather,EstimatedTime,RouteStatus0),
    ((RouteStatus0 = "NOT_SATISFIED" ; EstimatedTime > MaxTime) -> RouteStatus = "NOT_SATISFIED" ; RouteStatus = RouteStatus0),
    (Population =< Shelter -> ShelterStatus = "SUFFICIENT" ; ShelterStatus = "INSUFFICIENT"),
    (Communication = "unavailable" -> CommunicationStatus = "RISK" ; CommunicationStatus = "OK"),
    (FoodShortage =:= 0, MedicineShortage =:= 0, TeamShortage =:= 0, RouteStatus = "SATISFIED", ShelterStatus = "SUFFICIENT", CommunicationStatus = "OK" -> Overall = "FEASIBLE", Decision = "IMMEDIATE_RESPONSE" ; Overall = "NO FEASIBLE PLAN", Decision = "REASSESS_AND_ESCALATE"),
    reasoning(D, Score, FoodShortage, MedicineShortage, TeamShortage, EstimatedTime, MaxTime, RouteStatus, ShelterStatus, CommunicationStatus, Reasons),
    Output = _{success:true, disasterType:D.disasterType, area:D.area, priority:Level, priorityScore:Score,
      foodRequired:FoodReq, foodAllocated:FoodAllocated, foodShortage:FoodShortage,
      medicineRequired:MedReq, medicineAllocated:MedicineAllocated, medicineShortage:MedicineShortage,
      rescueRequired:TeamReq, rescueTeamsAllocated:TeamsAllocated, rescueShortage:TeamShortage,
      estimatedDeliveryTime:EstimatedTime, maxDeliveryTime:MaxTime, deliveryConstraint:RouteStatus,
      shelterStatus:ShelterStatus, communicationStatus:CommunicationStatus, overallStatus:Overall,
      decision:Decision, reasoning:Reasons}.

delivery_time(Distance, "blocked", _, 999, "NOT_SATISFIED") :- !.
delivery_time(Distance, Road, Weather, Time, Status) :-
    severity_value(Weather, WeatherDelay), (Road = "partially_blocked" -> RoadDelay = 1.5 ; RoadDelay = 0),
    Time0 is Distance/35 + RoadDelay + WeatherDelay/10,
    Time is round(Time0*10)/10, Status = "SATISFIED".

reasoning(D, Score, FS, MS, TS, Time, Max, Route, Shelter, Communication, Reasons) :-
    findall(R, reason(D,Score,FS,MS,TS,Time,Max,Route,Shelter,Communication,R), Reasons).
reason(D, Score, _, _, _, _, _, _, _, _, "Priority is high because the calculated score is at least 70.") :- Score >= 70.
reason(_, Score, _, _, _, _, _, _, _, _, "Priority is medium because the calculated score is between 40 and 69.") :- Score >= 40, Score < 70.
reason(_, Score, _, _, _, _, _, _, _, _, "Priority is low because the calculated score is below 40.") :- Score < 40.
reason(D, _, _, _, _, _, _, _, _, _, "Urgency level and affected population increased the response priority.") :- D.urgency >= 4.
reason(D, _, _, _, _, _, _, _, _, _, "Critical patients are present and increase medical priority.") :- D.criticalPatients > 0.
reason(D, _, _, _, _, _, _, _, _, _, "Severe weather increases both priority and delivery delay.") :- D.weatherSeverity = "severe".
reason(D, _, _, _, _, _, _, _, _, _, "Building damage increases the required rescue response.") :- member(D.buildingDamage, ["high","critical"]).
reason(_, _, FS, _, _, _, _, _, _, _, "Food allocation was limited by the available food constraint.") :- FS > 0.
reason(_, _, _, MS, _, _, _, _, _, _, "Medicine allocation was limited by the available medicine constraint.") :- MS > 0.
reason(_, _, _, _, TS, _, _, _, _, _, "Rescue teams were limited by the available team constraint.") :- TS > 0.
reason(D, _, _, _, _, _, _, _, _, _, "Shelter capacity is insufficient for the affected population.") :- D.population > D.shelterCapacity.
reason(_, _, _, _, _, Time, Max, _, _, _, "Estimated delivery time exceeds the maximum allowed time.") :- Time > Max.
reason(D, _, _, _, _, _, _, _, _, _, "Delivery time increased because the road is partially blocked.") :- D.roadStatus = "partially_blocked".
reason(_, _, _, _, _, _, _, "NOT_SATISFIED", _, _, "The delivery constraint cannot be satisfied under the current route and time limit.") :- true.
reason(_, _, _, _, _, _, _, _, _, "RISK", "Communication is unavailable, so field coordination remains a response risk.") :- true.