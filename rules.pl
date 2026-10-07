severity_value("normal", 0).
severity_value("moderate", 5).
severity_value("severe", 10).
damage_value("low", 0).
damage_value("medium", 5).
damage_value("high", 10).
damage_value("critical", 15).
communication_value("available", 0).
communication_value("limited", 4).
communication_value("unavailable", 8).

disaster_value("Flood", 8).
disaster_value("Earthquake", 12).
disaster_value("Cyclone", 10).
disaster_value("Fire", 9).
disaster_value("Landslide", 10).
disaster_value("Tsunami", 12).
disaster_value("Other", 6).

cap(Value, Max, Capped) :- (Value > Max -> Capped = Max ; Capped = Value).
priority_score(D, Score) :-
    get_dict(urgency,D,U), get_dict(criticalPatients,D,C), get_dict(population,D,P),
    get_dict(distance,D,Distance), get_dict(weatherSeverity,D,Weather),
    get_dict(waterLevel,D,Water), get_dict(buildingDamage,D,Damage),
    get_dict(communicationStatus,D,Communication), get_dict(disasterType,D,Type),
    cap(C,1000,C1), Crit is round(C1 / 50),
    cap(P,10000,P1), Pop is round(P1 / 667),
    cap(round(Water * 2),10,WaterPoints),
    cap(round(Distance / 10),10,DistancePenalty),
    severity_value(Weather, WeatherPoints), damage_value(Damage, DamagePoints),
    communication_value(Communication, CommunicationPoints), disaster_value(Type, DisasterPoints),
    Raw is U*10 + Crit + Pop + DisasterPoints + WeatherPoints + WaterPoints + DamagePoints + CommunicationPoints - DistancePenalty,
    (Raw < 0 -> Score = 0 ; Raw > 100 -> Score = 100 ; Score = Raw).

priority_level(Score, "HIGH") :- Score >= 70, !.
priority_level(Score, "MEDIUM") :- Score >= 40, !.
priority_level(_, "LOW").