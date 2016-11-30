-- postings_with_released_ownerships
CREATE VIEW yerdle_postings_with_released_ownerships_vw AS
SELECT postings.id,
  postings.ownership_id,
  postings.item_id,
  postings.poster_id,
  postings.created_at,
  postings.origin,
  postings.posting_transition_id,
  postings.posting_price_id,
  postings.yrd_price,
  postings.updated_at
--  ,postings.visit_id
FROM yerdle_postings AS postings
  JOIN yerdle_ownerships AS ownerships ON ownerships.id = postings.ownership_id
  LEFT JOIN yerdle_ownership_transitions AS ownership_transitions ON ownership_transitions.id = ownerships.ownership_transition_id
WHERE ownership_transitions.to_state::text = 'released'::text;

GRANT ALL ON analytics.yerdle_postings_with_released_ownerships_vw to group db_production_group;
GRANT SELECT ON analytics.yerdle_postings_with_released_ownerships_vw to group db_readonly_group;

-- flub_counts
CREATE VIEW yerdle_flub_counts_vw AS
SELECT users.id AS user_id,
       count(*) AS count
FROM yerdle_flubs AS flubs
  LEFT JOIN yerdle_users AS users ON users.id = flubs.user_id
GROUP BY users.id;

GRANT ALL ON analytics.yerdle_flub_counts_vw to group db_production_group;
GRANT SELECT ON analytics.yerdle_flub_counts_vw to group db_readonly_group;

-- pro_users view
CREATE VIEW yerdle_pro_users_vw AS
SELECT users.id                                                               AS user_id,
       received_give_counts.count                                             AS count_of_received_gives,
       COALESCE(flub_counts.count, 0 :: BIGINT) :: NUMERIC /
       (flub_counts.count :: NUMERIC + received_give_counts.count :: NUMERIC) AS flub_rate,
       users.admin_tags,
       users.updated_at                                                       AS last_active_at,
       users.email,
       users.first_name,
       users.last_name
FROM yerdle_users AS users
  LEFT JOIN yerdle_flub_counts_vw AS flub_counts ON users.id = flub_counts.user_id
  LEFT JOIN (SELECT
               postings_with_released_ownerships.poster_id AS user_id,
               count(*)                                    AS count
             FROM yerdle_postings_with_released_ownerships_vw AS postings_with_released_ownerships
             GROUP BY postings_with_released_ownerships.poster_id) AS received_give_counts
    ON users.id = received_give_counts.user_id
  LEFT JOIN yerdle_echelon_transitions AS et1 ON users.id = et1.user_id
  LEFT JOIN yerdle_echelon_transitions AS et2 ON users.id = et2.user_id AND et2.sort_key > et1.sort_key
WHERE
  users.deleted_at IS NULL AND et2.id IS NULL AND et1.to_state::text = 'pro'::text AND users.suspended_at IS NULL AND users.closed_at IS NULL;

GRANT ALL ON analytics.yerdle_pro_users_vw to group db_production_group;
GRANT SELECT ON analytics.yerdle_pro_users_vw to group db_readonly_group;