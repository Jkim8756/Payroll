-- ================================================
-- FINAL JOINED PAYROLL TABLE
-- ================================================

SELECT 
    COALESCE(d."Employee ID", e."Employee ID", t."Employee ID") AS "Employee ID",
    COALESCE(d."Last Name", e."Last Name", t."Last Name") AS "Last Name",
    COALESCE(d."First Name", e."First Name", t."First Name") AS "First Name",
    COALESCE(d."Job Title", e."Job Title", t."Job Title") AS "Job Title",
    COALESCE(d."Check Detail Week Number", e."Check Detail Week Number", t."Check Detail Week Number") AS "Week_Number",
    COALESCE(d."Period End Date", e."Period End Date", t."Period End Date") AS "Period_End_Date",
    COALESCE(d."Check Detail Period Begin Date", e."Check Detail Period Begin Date", t."Check Detail Period Begin Date") AS "Period_Begin_Date",
    COALESCE(d."Worked in PTT", e."Worked in PTT", t."Worked in PTT") AS "Worked_in_PTT",

    COALESCE(d."Check Detail Deduction Amount", 0) AS "Total_Deductions",
    COALESCE(e."Hours", 0) AS "Total_Hours",
    COALESCE(e."Earnings", 0) AS "Total_Earnings",

    COALESCE(t."Check Detail Federal Tax Amount", 0) AS "Total_Federal_Tax",
    COALESCE(t."Check Detail Worked In State Tax Amount", 0) AS "Total_State_Tax",
    COALESCE(t."Check Detail Medicare Tax Amount", 0) AS "Total_Medicare_Tax",
    COALESCE(t."FLI Tax Amount", 0) AS "Total_FLI_Tax",
    COALESCE(t."Check Detail Social Security Amount", 0) AS "Total_Social_Security",

    -- Total Tax
    (COALESCE(t."Check Detail Federal Tax Amount", 0) +
     COALESCE(t."Check Detail Worked In State Tax Amount", 0) +
     COALESCE(t."Check Detail Medicare Tax Amount", 0) +
     COALESCE(t."FLI Tax Amount", 0) +
     COALESCE(t."Check Detail Social Security Amount", 0)) AS "Total_Tax_Amount",

    -- Net Pay
    (COALESCE(e."Earnings", 0) - 
     COALESCE(d."Check Detail Deduction Amount", 0) - 
     (COALESCE(t."Check Detail Federal Tax Amount", 0) +
      COALESCE(t."Check Detail Worked In State Tax Amount", 0) +
      COALESCE(t."Check Detail Medicare Tax Amount", 0) +
      COALESCE(t."FLI Tax Amount", 0) +
      COALESCE(t."Check Detail Social Security Amount", 0))) AS "Net_Pay"

FROM "DeD" d
FULL OUTER JOIN "ear" e 
    ON  d."Employee ID" = e."Employee ID"
    AND d."Check Detail Week Number" = e."Check Detail Week Number"
    AND d."Period End Date" = e."Period End Date"
    AND d."Check Detail Period Begin Date" = e."Check Detail Period Begin Date"
    AND d."Worked in PTT" = e."Worked in PTT"
    AND d."Job Title" = e."Job Title"
FULL OUTER JOIN "tax" t 
    ON COALESCE(d."Employee ID", e."Employee ID") = t."Employee ID"
    AND COALESCE(d."Check Detail Week Number", e."Check Detail Week Number") = t."Check Detail Week Number"
    AND COALESCE(d."Period End Date", e."Period End Date") = t."Period End Date"
    AND COALESCE(d."Check Detail Period Begin Date", e."Check Detail Period Begin Date") = t."Check Detail Period Begin Date"
    AND COALESCE(d."Worked in PTT", e."Worked in PTT") = t."Worked in PTT"
    AND COALESCE(d."Job Title", e."Job Title") = t."Job Title"

ORDER BY "Period_End_Date" DESC, "Last Name" ASC;



-- ================================================
-- FINAL FIXED GRAND TOTALS - NO ROUND ERROR
-- ================================================

WITH ded_agg AS (
    SELECT 
        "Employee ID",
        "Check Detail Week Number",
        "Period End Date",
        SUM("Check Detail Deduction Amount"::numeric) AS Total_Deductions
    FROM "DeD"
    GROUP BY "Employee ID", "Check Detail Week Number", "Period End Date"
),

ear_agg AS (
    SELECT 
        "Employee ID",
        "Check Detail Week Number",
        "Period End Date",
        SUM("Hours"::numeric) AS Total_Hours,
        SUM("Earnings"::numeric) AS Total_Earnings
    FROM "ear"
    GROUP BY "Employee ID", "Check Detail Week Number", "Period End Date"
),

tax_agg AS (
    SELECT 
        "Employee ID",
        "Check Detail Week Number",
        "Period End Date",
        SUM("Check Detail Federal Tax Amount"::numeric) AS Total_Federal_Tax,
        SUM("Check Detail Worked In State Tax Amount"::numeric) AS Total_State_Tax,
        SUM("Check Detail Social Security Amount"::numeric) AS Total_Social_Security,
        SUM("Check Detail Medicare Tax Amount"::numeric) AS Total_Medicare_Tax,
        SUM("FLI Tax Amount"::numeric) AS Total_FLI_Tax
    FROM "tax"
    GROUP BY "Employee ID", "Check Detail Week Number", "Period End Date"
)

SELECT 
    COUNT(DISTINCT COALESCE(d."Employee ID", e."Employee ID", t."Employee ID")) AS total_employees,
    COUNT(DISTINCT COALESCE(d."Period End Date", e."Period End Date", t."Period End Date")) AS total_pay_periods,

    ROUND(SUM(COALESCE(d.Total_Deductions, 0)), 2) AS "Total_Deductions",
    ROUND(SUM(COALESCE(e.Total_Hours, 0)), 2) AS "Total_Hours",
    ROUND(SUM(COALESCE(e.Total_Earnings, 0)), 2) AS "Total_Earnings",

    ROUND(SUM(COALESCE(t.Total_Federal_Tax, 0)), 2) AS "Total_Federal_Tax",
    ROUND(SUM(COALESCE(t.Total_State_Tax, 0)), 2) AS "Total_State_Tax",
    ROUND(SUM(COALESCE(t.Total_Medicare_Tax, 0)), 2) AS "Total_Medicare_Tax",
    ROUND(SUM(COALESCE(t.Total_FLI_Tax, 0)), 2) AS "Total_FLI_Tax",
    ROUND(SUM(COALESCE(t.Total_Social_Security, 0)), 2) AS "Total_Social_Security",

    ROUND(
        SUM(COALESCE(t.Total_Federal_Tax, 0)) +
        SUM(COALESCE(t.Total_State_Tax, 0)) +
        SUM(COALESCE(t.Total_Medicare_Tax, 0)) +
        SUM(COALESCE(t.Total_FLI_Tax, 0)) +
        SUM(COALESCE(t.Total_Social_Security, 0))
    , 2) AS "Total_Tax_Amount",

    ROUND(
        SUM(COALESCE(e.Total_Earnings, 0)) -
        SUM(COALESCE(d.Total_Deductions, 0)) -
        SUM(COALESCE(t.Total_Federal_Tax, 0) + 
            COALESCE(t.Total_State_Tax, 0) + 
            COALESCE(t.Total_Medicare_Tax, 0) + 
            COALESCE(t.Total_FLI_Tax, 0) + 
            COALESCE(t.Total_Social_Security, 0))
    , 2) AS "Net_Pay"

FROM ded_agg d
FULL OUTER JOIN ear_agg e 
    ON d."Employee ID" = e."Employee ID"
    AND d."Check Detail Week Number" = e."Check Detail Week Number"
    AND d."Period End Date" = e."Period End Date"
FULL OUTER JOIN tax_agg t 
    ON COALESCE(d."Employee ID", e."Employee ID") = t."Employee ID"
    AND COALESCE(d."Check Detail Week Number", e."Check Detail Week Number") = t."Check Detail Week Number"
    AND COALESCE(d."Period End Date", e."Period End Date") = t."Period End Date";