const numericFields = [
  "population", "criticalPatients", "urgency", "distance", "foodRequired",
  "medicineRequired", "rescueRequired", "availableFood", "availableMedicine",
  "availableTeams", "waterLevel", "shelterCapacity", "maxDeliveryTime"
];

const enumFields = {
  disasterType: ["Flood", "Earthquake", "Cyclone", "Fire", "Landslide", "Tsunami", "Other"],
  roadStatus: ["open", "partially_blocked", "blocked"],
  weatherSeverity: ["normal", "moderate", "severe"],
  buildingDamage: ["low", "medium", "high", "critical"],
  communicationStatus: ["available", "limited", "unavailable"]
};

export function validateInput(input) {
  const errors = [];
  if (!input || typeof input !== "object" || Array.isArray(input)) {
    return ["A JSON object is required."];
  }

  if (!String(input.area ?? "").trim()) errors.push("Affected area is required.");
  for (const field of ["disasterType", ...Object.keys(enumFields)]) {
    if (input[field] === undefined || input[field] === null || input[field] === "") {
      errors.push(`${field} is required.`);
    } else if (enumFields[field] && !enumFields[field].includes(input[field])) {
      errors.push(`${field} must be one of: ${enumFields[field].join(", ")}.`);
    }
  }

  for (const field of numericFields) {
    const value = input[field];
    if (value === undefined || value === null || value === "") {
      errors.push(`${field} is required.`);
    } else if (typeof value !== "number" || !Number.isFinite(value)) {
      errors.push(`${field} must be a finite number.`);
    }
  }

  const nonNegative = numericFields.filter((field) => field !== "urgency" && field !== "maxDeliveryTime");
  for (const field of nonNegative) {
    if (typeof input[field] === "number" && input[field] < 0) errors.push(`${field} cannot be negative.`);
  }
  if (typeof input.urgency === "number" && (!Number.isInteger(input.urgency) || input.urgency < 1 || input.urgency > 5)) {
    errors.push("urgency must be an integer from 1 to 5.");
  }
  if (typeof input.maxDeliveryTime === "number" && input.maxDeliveryTime <= 0) {
    errors.push("maxDeliveryTime must be greater than zero.");
  }
  for (const field of ["population", "criticalPatients", "foodRequired", "medicineRequired", "rescueRequired", "availableFood", "availableMedicine", "availableTeams", "shelterCapacity"]) {
    if (typeof input[field] === "number" && !Number.isInteger(input[field])) errors.push(`${field} must be an integer.`);
  }
  if (typeof input.criticalPatients === "number" && typeof input.population === "number" && input.criticalPatients > input.population) {
    errors.push("criticalPatients cannot be greater than population.");
  }
  return [...new Set(errors)];
}