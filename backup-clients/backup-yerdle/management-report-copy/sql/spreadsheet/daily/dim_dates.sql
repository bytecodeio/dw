-- ************************************************************************************
--  dim_date
--  Generate dates
-- ************************************************************************************

CREATE TABLE etl_dates
(
  date DATE SORTKEY
);
GRANT ALL ON analytics.etl_dates to group db_production_group;
GRANT SELECT ON analytics.etl_dates to group db_readonly_group;

etl_numbers

CREATE TABLE analytics.dim_date
(
  date DATE SORTKEY,
  year SMALLINT DISTKEY,
  month SMALLINT,
  monthname VARCHAR(16),
  day SMALLINT,
  dayofyear SMALLINT,
  weekdayname VARCHAR(16),
  calendarweek SMALLINT,
  formatteddate VARCHAR(16),
  quartal VARCHAR(2),
  yearquartal VARCHAR(8),
  yearmonth VARCHAR(8),
  yearcalendarweek VARCHAR(8),
  weekend VARCHAR(8),
  americanholiday VARCHAR(16),
  austrianholiday VARCHAR(16),
  canadianholiday VARCHAR(16),
  period VARCHAR(24),
  cwstart DATE,
  cwend DATE,
  monthstart DATE,
  monthend DATE
);
GRANT ALL ON analytics.yerdle_posting_transitions_dv to group db_production_group;
GRANT SELECT ON analytics.yerdle_posting_transitions_dv to group db_readonly_group;

SELECT
  datum AS DATE,
  EXTRACT(YEAR FROM datum) AS YEAR,
  EXTRACT(MONTH FROM datum) AS MONTH,
  -- Localized month name
  to_char(datum, 'Month') AS MonthName,
  EXTRACT(DAY FROM datum) AS DAY,
  EXTRACT(doy FROM datum) AS DayOfYear,
  -- Localized weekday
  to_char(datum, 'Day') AS WeekdayName,
  -- ISO calendar week
  EXTRACT(week FROM datum) AS CalendarWeek,
  to_char(datum, 'DD/MM/YYYY') AS FormattedDate,
  'Q' || to_char(datum, 'Q') AS Quartal,
  to_char(datum, 'yyyy/"Q"Q') AS YearQuartal,
  to_char(datum, 'yyyy/mm') AS YearMonth,
  -- ISO calendar year and week
  to_char(datum, 'iyyy/IW') AS YearCalendarWeek,
  -- Weekend
  CASE WHEN EXTRACT(dow FROM datum) IN (5, 6) THEN 'Weekend' ELSE 'Weekday' END AS Weekend,
  -- Fixed holidays
        -- for America
  CASE WHEN to_char(datum, 'MMDD') IN ('0101', '0704', '1225', '1226')
    THEN 'Holiday' ELSE 'No holiday' END
    AS AmericanHoliday,
  -- for Austria
  CASE WHEN to_char(datum, 'MMDD') IN
            ('0101', '0106', '0501', '0815', '1101', '1208', '1225', '1226')
    THEN 'Holiday' ELSE 'No holiday' END
    AS AustrianHoliday,
  -- for Canada
  CASE WHEN to_char(datum, 'MMDD') IN ('0101', '0701', '1225', '1226')
    THEN 'Holiday' ELSE 'No holiday' END
    AS CanadianHoliday,
  -- Some periods of the year, adjust for your organisation and country
  CASE WHEN to_char(datum, 'MMDD') BETWEEN '0701' AND '0831' THEN 'Summer break'
  WHEN to_char(datum, 'MMDD') BETWEEN '1115' AND '1225' THEN 'Christmas season'
  WHEN to_char(datum, 'MMDD') > '1225' OR to_char(datum, 'MMDD') <= '0106' THEN 'Winter break'
  ELSE 'Normal' END
    AS Period,
  -- ISO start and end of the week of this date
  datum + (0 - EXTRACT(dow FROM datum))::INTEGER AS CWStart,
  datum + (6 - EXTRACT(dow FROM datum))::INTEGER AS CWEnd,
  -- Start and end of the month of this date
  datum + (1 - EXTRACT(DAY FROM datum))::INTEGER AS MonthStart,
  ((datum + (1 - EXTRACT(DAY FROM datum))::INTEGER + '1 month'::INTERVAL)::DATE - '1 day'::INTERVAL)::DATE AS MonthEnd
FROM (
       -- There are 3 leap years in this range, so calculate 365 * 10 + 3 records
      SELECT '2013-01-01'::DATE + SEQUENCE.DAY AS datum
      FROM generate_series(0,3651) AS SEQUENCE(DAY)
      GROUP BY SEQUENCE.DAY ORDER BY SEQUENCE.DAY ASC
     ) AS DQ
ORDER BY 1 ASC
;



