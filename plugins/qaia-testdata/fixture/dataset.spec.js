// Minimal proof that the generated dataset (US-002-dosage-dataset.json) is real, coherent,
// and injectable via a Playwright fixture — not just structurally valid JSON. No app under
// test is needed: this validates the fixture-data layer itself, per the acceptance criterion
// "datasets coherents generes ... injectables via fixtures (T3)" (issue #15).
const { test, expect } = require('./fixtures');

test.describe('US-002 dosage dataset — structural + referential integrity', () => {
  test('_meta carries a non-fabrication disclaimer and named assumptions', async ({ testData }) => {
    expect(testData._meta).toBeTruthy();
    expect(testData._meta.disclaimer).toMatch(/synthetic/i);
    expect(testData._meta.assumptions.length).toBeGreaterThanOrEqual(3);
    for (const a of testData._meta.assumptions) {
      expect(a.id).toMatch(/^ASM-\d+$/);
      expect(a.text.length).toBeGreaterThan(10);
    }
  });

  test('every drug reference record is complete, coherent and flagged synthetic', async ({ testData }) => {
    expect(testData.drugs.length).toBeGreaterThanOrEqual(4);
    for (const d of testData.drugs) {
      expect(d.synthetic).toBe(true);
      expect(typeof d.minEffectiveDose).toBe('number');
      expect(typeof d.maxSafeDosePerIntake).toBe('number');
      expect(typeof d.maxCumulativeDose24h).toBe('number');
      expect(typeof d.ageFloorYears).toBe('number');
      // business coherence: min < per-intake max <= cumulative max
      expect(d.minEffectiveDose).toBeLessThan(d.maxSafeDosePerIntake);
      expect(d.maxSafeDosePerIntake).toBeLessThanOrEqual(d.maxCumulativeDose24h);
    }
  });

  test('every person-like entity is synthetic and PII-safe', async ({ testData }) => {
    const people = [...testData.patients, ...testData.physicians];
    expect(people.length).toBeGreaterThan(0);
    for (const p of people) {
      expect(p.synthetic).toBe(true);
      expect(p.email).toMatch(/@example\.invalid$/);
      expect(p.name).toMatch(/Sample-\d+/);
    }
  });

  test('every drug/patient/physician referenced by an intake actually exists (referential integrity)', async ({ testData }) => {
    const drugIds = new Set(testData.drugs.map((d) => d.id));
    const patientIds = new Set(testData.patients.map((p) => p.id));
    const physicianIds = new Set(testData.physicians.map((p) => p.id));
    expect(testData.intakes.length).toBeGreaterThan(0);
    for (const i of testData.intakes) {
      expect(drugIds.has(i.drugId)).toBe(true);
      expect(patientIds.has(i.patientId)).toBe(true);
      expect(physicianIds.has(i.physicianId)).toBe(true);
      expect(typeof i.dosageMg).toBe('number');
    }
  });

  test('no drug, patient or physician is dead fixture weight (every one is used by at least one intake)', async ({ testData }) => {
    const usedDrugIds = new Set(testData.intakes.map((i) => i.drugId));
    const usedPatientIds = new Set(testData.intakes.map((i) => i.patientId));
    const usedPhysicianIds = new Set(testData.intakes.map((i) => i.physicianId));
    for (const d of testData.drugs) expect(usedDrugIds.has(d.id)).toBe(true);
    for (const p of testData.patients) expect(usedPatientIds.has(p.id)).toBe(true);
    for (const p of testData.physicians) expect(usedPhysicianIds.has(p.id)).toBe(true);
  });

  test('every case references intakes that exist, and cumulative totals are internally consistent', async ({ testData }) => {
    const intakeById = new Map(testData.intakes.map((i) => [i.id, i]));
    expect(testData.cases.length).toBeGreaterThan(0);
    for (const c of testData.cases) {
      expect(Array.isArray(c.intakeRefs)).toBe(true);
      for (const ref of c.intakeRefs) {
        expect(intakeById.has(ref)).toBe(true);
      }
      if (c.cumulativeCheck) {
        const sum = c.intakeRefs.reduce((acc, ref) => acc + intakeById.get(ref).dosageMg, 0);
        expect(sum).toBe(c.cumulativeCheck.expectedTotalMg);
      }
    }
  });

  test('AC1 through AC8 are each covered by at least one case', async ({ testData }) => {
    const covered = new Set(testData.cases.flatMap((c) => c.coversAC));
    for (let ac = 1; ac <= 8; ac++) {
      expect(covered.has(`AC${ac}`)).toBe(true);
    }
  });

  test('AC7 justification length boundary is exact, computed not eyeballed', async ({ testData }) => {
    const valid = testData.cases.find((c) => c.id === 'C-012');
    const invalid = testData.cases.find((c) => c.id === 'C-013');
    expect(valid.overrideJustification.length).toBe(20);
    expect(valid.expectedResult.ruleIds).toContain('AC7-override-valid');
    expect(invalid.overrideJustification.length).toBe(19);
    expect(invalid.expectedResult.ruleIds).toContain('AC7-override-rejected-too-short');
  });

  test('the genuinely open AC6 ambiguity (C-015) is exposed, not silently resolved', async ({ testData }) => {
    const c015 = testData.cases.find((c) => c.id === 'C-015');
    expect(c015).toBeTruthy();
    expect(c015.expectedResult.status).toBe('[open]');
    expect(c015.expectedResult.interpretations.length).toBe(2);
    expect(c015.assumptionRefs).toContain('ASM-3');
  });

  test('boundary cases sit exactly at the threshold they claim (computed, not approximate)', async ({ testData }) => {
    const drugById = new Map(testData.drugs.map((d) => [d.id, d]));
    const intakeById = new Map(testData.intakes.map((i) => [i.id, i]));

    const atMin = intakeById.get('INT-001');
    expect(atMin.dosageMg).toBe(drugById.get(atMin.drugId).minEffectiveDose);

    const atMax = intakeById.get('INT-003');
    expect(atMax.dosageMg).toBe(drugById.get(atMax.drugId).maxSafeDosePerIntake);

    const overMax = intakeById.get('INT-004');
    expect(overMax.dosageMg).toBe(drugById.get(overMax.drugId).maxSafeDosePerIntake + 1);

    const renalAtReducedMax = testData.cases.find((c) => c.id === 'C-011');
    const renalIntake = intakeById.get(renalAtReducedMax.intakeRefs[0]);
    expect(renalIntake.dosageMg).toBe(renalAtReducedMax.renalReducedMaxSafeDosePerIntake);
    expect(renalAtReducedMax.renalReducedMaxSafeDosePerIntake).toBe(
      drugById.get(renalIntake.drugId).maxSafeDosePerIntake / 2
    );
  });
});
