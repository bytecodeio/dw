-- ************************************************************************************
--  posting_transitions_dv
--  Flatten posting events for inventory counts
-- ************************************************************************************

CREATE TABLE analytics.yerdle_posting_transitions_dv
(
  posting_id INTEGER DISTKEY ENCODE DELTA,
  granting_dt TIMESTAMP ENCODE LZO,
  up_dt TIMESTAMP ENCODE LZO,
  claimed_dt TIMESTAMP ENCODE LZO,
  expired_dt TIMESTAMP ENCODE LZO,
  user_pulled_dt TIMESTAMP ENCODE LZO,
  admin_pulled_dt TIMESTAMP ENCODE LZO,
  in_inventory_dt TIMESTAMP SORTKEY ENCODE LZO,
  out_inventory_dt TIMESTAMP ENCODE LZO
);
GRANT ALL ON analytics.yerdle_posting_transitions_dv to group db_production_group;
GRANT SELECT ON analytics.yerdle_posting_transitions_dv to group db_readonly_group;

-- Insert new ids from postings table.
INSERT INTO analytics.yerdle_posting_transitions_dv (posting_id)
    SELECT DISTINCT id FROM yerdle_postings WHERE id NOT IN
      (SELECT DISTINCT posting_id FROM yerdle_posting_transitions_dv)
;

-- Update states
UPDATE yerdle_posting_transitions_dv
SET granting_dt = yerdle_posting_transitions.created_at
FROM yerdle_posting_transitions
WHERE yerdle_posting_transitions.posting_id = yerdle_posting_transitions_dv.posting_id
      AND yerdle_posting_transitions.to_state = 'granting'
      AND yerdle_posting_transitions_dv.granting_dt is NULL;

UPDATE yerdle_posting_transitions_dv
SET up_dt = yerdle_posting_transitions.created_at
FROM yerdle_posting_transitions
WHERE yerdle_posting_transitions.posting_id = yerdle_posting_transitions_dv.posting_id
      AND yerdle_posting_transitions.to_state = 'up'
      AND yerdle_posting_transitions_dv.up_dt is NULL;

UPDATE yerdle_posting_transitions_dv
SET claimed_dt = yerdle_posting_transitions.created_at
FROM yerdle_posting_transitions
WHERE yerdle_posting_transitions.posting_id = yerdle_posting_transitions_dv.posting_id
      AND yerdle_posting_transitions.to_state = 'claimed'
      AND yerdle_posting_transitions_dv.claimed_dt is NULL;

UPDATE yerdle_posting_transitions_dv
SET expired_dt = yerdle_posting_transitions.created_at
FROM yerdle_posting_transitions
WHERE yerdle_posting_transitions.posting_id = yerdle_posting_transitions_dv.posting_id
      AND yerdle_posting_transitions.to_state = 'expired'
      AND yerdle_posting_transitions_dv.expired_dt is NULL;

UPDATE yerdle_posting_transitions_dv
SET admin_pulled_dt = yerdle_posting_transitions.created_at
FROM yerdle_posting_transitions
WHERE yerdle_posting_transitions.posting_id = yerdle_posting_transitions_dv.posting_id
      AND yerdle_posting_transitions.to_state = 'admin_pulled'
      AND yerdle_posting_transitions_dv.admin_pulled_dt is NULL;

UPDATE yerdle_posting_transitions_dv
SET user_pulled_dt = yerdle_posting_transitions.created_at
FROM yerdle_posting_transitions
WHERE yerdle_posting_transitions.posting_id = yerdle_posting_transitions_dv.posting_id
      AND yerdle_posting_transitions.to_state = 'user_pulled'
      AND yerdle_posting_transitions_dv.user_pulled_dt is NULL;

-- Set in_inventory_dt and out_inventory_dt
UPDATE yerdle_posting_transitions_dv
SET in_inventory_dt = granting_dt
WHERE in_inventory_dt IS NULL
AND granting_dt IS NOT NULL;

UPDATE yerdle_posting_transitions_dv
SET out_inventory_dt = LEAST(claimed_dt, expired_dt, admin_pulled_dt, user_pulled_dt)
WHERE out_inventory_dt IS NULL
AND (claimed_dt IS NOT NULL OR expired_dt IS NOT NULL OR admin_pulled_dt IS NOT NULL OR user_pulled_dt IS NOT NULL);




/*
granting, admin_pulled, up, claimed, expired, user_pulled

1. granting
2. up
3. claimed
4. expired
5. admin_pulled
6. user_pulled

posting

production=# select count(*), to_state from analytics.yerdle_posting_transitions group by to_state;
 count  |   to_state
--------+--------------
  56379 | expired
 136779 | user_pulled
 707713 | up
 471857 | claimed
 396834 | granting
  10810 | admin_pulled
(6 rows)

production=# \d yerdle_posting_transitions;
        Table "analytics.yerdle_posting_transitions"
      Column       |            Type             | Modifiers
-------------------+-----------------------------+-----------
 id                | integer                     |
 to_state          | character varying(65535)    |
 metadata          | character varying(65535)    |
 sort_key          | integer                     |
 posting_id        | integer                     |
 created_at        | timestamp without time zone |
 updated_at        | timestamp without time zone |
 down_after        | timestamp without time zone |
 granting_at       | timestamp without time zone |
 granted_wish_term | character varying(256)      |
 down_at           | timestamp without time zone |
 granted_wish_id   | integer                     |
 up_at             | timestamp without time zone |
 to_location       | character varying(1024)     |
 claimer_id        | integer                     |

*/