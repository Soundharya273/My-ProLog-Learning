import test from "node:test";
import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { optimizeWithProlog } from "../src/services/prologService.js";

const swipl = process.env.SWIPL_PATH || (process.platform === "win32" ? "swipl.exe" : "swipl");
let hasSwipl = false;
try {
  execFileSync(swipl, ["--version"], { stdio: "ignore" });
  hasSwipl = true;
} catch {}

const sample = {
  disasterType: "Flood", area: "Area A", population: 5000, criticalPatients: 120,
  urgency: 5, distance: 15, foodRequired: 2000, medicineRequired: 500, rescueRequired: 4,
  availableFood: 5000, availableMedicine: 1500, availableTeams: 10, roadStatus: "open",
  weatherSeverity: "severe", waterLevel: 4.5, buildingDamage: "high",
  communicationStatus: "available", shelterCapacity: 3000, maxDeliveryTime: 4
};

test("valid flood input returns a feasible Prolog plan", { skip: !hasSwipl }, async () => {
  const result = await optimizeWithProlog(sample);
  assert.equal(result.success, true);
  assert.ok(["HIGH", "MEDIUM", "LOW"].includes(result.priority));
  assert.equal(result.overallStatus, "FEASIBLE");
});

test("low urgency changes priority from the high-urgency scenario", { skip: !hasSwipl }, async () => {
  const high = await optimizeWithProlog(sample);
  const low = await optimizeWithProlog({ ...sample, urgency: 1, criticalPatients: 5, weatherSeverity: "normal", buildingDamage: "low" });
  assert.notEqual(high.priorityScore, low.priorityScore);
});

test("blocked road makes the delivery constraint unsatisfied", { skip: !hasSwipl }, async () => {
  const result = await optimizeWithProlog({ ...sample, roadStatus: "blocked" });
  assert.equal(result.deliveryConstraint, "NOT_SATISFIED");
  assert.equal(result.overallStatus, "NO FEASIBLE PLAN");
});

test("insufficient medicine is returned as a shortage", { skip: !hasSwipl }, async () => {
  const result = await optimizeWithProlog({ ...sample, availableMedicine: 100 });
  assert.equal(result.medicineAllocated, 100);
  assert.equal(result.medicineShortage, 400);
});

test("insufficient shelter is reported", { skip: !hasSwipl }, async () => {
  const result = await optimizeWithProlog({ ...sample, shelterCapacity: 100 });
  assert.equal(result.shelterStatus, "INSUFFICIENT");
  assert.equal(result.overallStatus, "NO FEASIBLE PLAN");
});