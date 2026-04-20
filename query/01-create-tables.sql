-- Drop tables if they exist (safe to run multiple times)
DROP TABLE IF EXISTS "DeD";
DROP TABLE IF EXISTS "ear";
DROP TABLE IF EXISTS "tax";

-- Create the three tables with correct types
CREATE TABLE "DeD" (
    "Employee ID" BIGINT,
    "Last Name" TEXT,
    "First Name" TEXT,
    "Job Title" TEXT,
    "Check Detail Week Number" INTEGER,
    "Period End Date" DATE,
    "Check Detail Period Begin Date" DATE,
    "Worked in PTT" NUMERIC(12,2),
    "Check Detail Deduction Amount" NUMERIC(12,2)
);

CREATE TABLE "ear" (
    "Employee ID" BIGINT,
    "Last Name" TEXT,
    "First Name" TEXT,
    "Job Title" TEXT,
    "Check Detail Week Number" INTEGER,
    "Period End Date" DATE,
    "Check Detail Period Begin Date" DATE,
    "Worked in PTT" NUMERIC(12,2),
    "Hours" NUMERIC(12,2),
    "Earnings" NUMERIC(12,2)
);

CREATE TABLE "tax" (
    "Employee ID" BIGINT,
    "Last Name" TEXT,
    "First Name" TEXT,
    "Job Title" TEXT,
    "Check Detail Week Number" INTEGER,
    "Period End Date" DATE,
    "Check Detail Period Begin Date" DATE,
    "Worked in PTT" NUMERIC(12,2),
    "Check Detail Federal Tax Amount" NUMERIC(12,2),
    "Check Detail Worked In State Tax Amount" NUMERIC(12,2),
    "Check Detail Social Security Amount" NUMERIC(12,2),
    "Check Detail Medicare Tax Amount" NUMERIC(12,2),
    "FLI Tax Amount" NUMERIC(12,2)
);