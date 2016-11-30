SELECT
  month,
  count(*)
FROM (
  SELECT
    TO_CHAR(DATE_TRUNC('month', yerdle_invoices.created_at), 'YYYY-MM-DD') AS month,
    yerdle_invoices.id AS id
  FROM yerdle_invoices
    LEFT JOIN yerdle_transfers ON yerdle_invoices.delivery_id = yerdle_transfers.delivery_id
  WHERE
    yerdle_invoices.created_at >= '2015-01-01' AND yerdle_invoices.created_at < TO_CHAR(CURRENT_DATE, 'YYYY-MM-01')
  GROUP BY 1, 2
  HAVING count(*) > 1
  ) AS bundles
GROUP BY 1
ORDER BY 1 DESC

/*
Transfers
Deliveries
Postings

d9t4qt8assu9io=> \d transfers;
                                      Table "public.transfers"
    Column    |            Type             |                       Modifiers
--------------+-----------------------------+--------------------------------------------------------
 id           | integer                     | not null default nextval('transfers_id_seq'::regclass)
 ownership_id | integer                     |
 posting_id   | integer                     |
 to_user_id   | integer                     |
 from_user_id | integer                     |
 delivery_id  | integer                     |
 created_at   | timestamp without time zone | not null
 updated_at   | timestamp without time zone | not null
Indexes:
    "transfers_pkey" PRIMARY KEY, btree (id)
    "index_transfers_on_delivery_id" btree (delivery_id)
    "index_transfers_on_from_user_id" btree (from_user_id)
    "index_transfers_on_ownership_id" btree (ownership_id)
    "index_transfers_on_posting_id" btree (posting_id)
    "index_transfers_on_to_user_id" btree (to_user_id)
Triggers:
    transfers_cache_id_on_ownership AFTER INSERT ON transfers FOR EACH ROW EXECUTE PROCEDURE cache_transfer_id_on_ownership()

d9t4qt8assu9io=> \d deliveries;
                                               Table "public.deliveries"
             Column             |            Type             |                        Modifiers
--------------------------------+-----------------------------+---------------------------------------------------------
 id                             | integer                     | not null default nextval('deliveries_id_seq'::regclass)
 easypost_shipment_id           | character varying(255)      |
 easypost_payment_response_json | text                        |
 label_url                      | character varying(255)      |
 tracking_code                  | character varying(255)      |
 created_at                     | timestamp without time zone |
 updated_at                     | timestamp without time zone |
 city                           | character varying(255)      |
 state                          | character varying(255)      |
 shipped_at                     | timestamp without time zone |
 p2p                            | boolean                     | default true
 tracking_status                | character varying(255)      | default NULL::character varying
 tracking_details               | text                        |
 payment_transaction_id         | character varying(255)      |
 street1                        | character varying(255)      |
 street2                        | character varying(255)      |
 zipcode                        | character varying(255)      |
 phone                          | character varying(255)      |
 zpl_url                        | character varying(255)      |
 type                           | character varying(255)      |
 deleted_at                     | timestamp without time zone |
 transitioned_at                | timestamp without time zone |
 timeout_at                     | timestamp without time zone |
 address_name                   | character varying(255)      |
 posting_id                     | integer                     |
 shipping_paid_at               | timestamp without time zone |
 yrd_exchanged_at               | timestamp without time zone |
 received_at                    | timestamp without time zone |
 poster_id                      | integer                     |
 claimer_id                     | integer                     |
 old_ownership_id               | integer                     |
Indexes:
    "shipments_pkey" PRIMARY KEY, btree (id)
    "index_deliveries_on_claimer_id" btree (claimer_id)
    "index_deliveries_on_easypost_shipment_id" btree (easypost_shipment_id)
    "index_deliveries_on_old_ownership_id" btree (old_ownership_id)
    "index_deliveries_on_p2p" btree (p2p)
    "index_deliveries_on_payment_transaction_id" btree (payment_transaction_id)
    "index_deliveries_on_poster_id" btree (poster_id)
    "index_deliveries_on_posting_id" btree (posting_id)
    "index_deliveries_on_received_at" btree (received_at)
    "index_deliveries_on_shipped_at" btree (shipped_at)
    "index_deliveries_on_shipping_paid_at" btree (shipping_paid_at)
    "index_deliveries_on_timeout_at" btree (timeout_at)

d9t4qt8assu9io=> \d postings;
                                           Table "public.postings"
        Column         |            Type             |                       Modifiers
-----------------------+-----------------------------+-------------------------------------------------------
 id                    | integer                     | not null default nextval('postings_id_seq'::regclass)
 ownership_id          | integer                     |
 item_id               | integer                     |
 poster_id             | integer                     |
 created_at            | timestamp without time zone |
 origin                | character varying           |
 posting_transition_id | integer                     |
 posting_price_id      | integer                     |
 yrd_price             | numeric                     |
Indexes:
    "postings_pkey" PRIMARY KEY, btree (id)
    "index_postings_on_item_id" btree (item_id)
    "index_postings_on_ownership_id" btree (ownership_id)
    "index_postings_on_poster_id" btree (poster_id)
    "index_postings_on_posting_price_id" btree (posting_price_id)
    "index_postings_on_posting_transition_id" btree (posting_transition_id)
Triggers:
    postings_cache_id_on_item AFTER INSERT ON postings FOR EACH ROW EXECUTE PROCEDURE cache_posting_id_on_item()
    postings_cache_id_on_ownership AFTER INSERT ON postings FOR EACH ROW EXECUTE PROCEDURE cache_posting_id_on_ownership()

    9t4qt8assu9io=> \d invoices;
                                         Table "public.invoices"
       Column       |            Type             |                       Modifiers
--------------------+-----------------------------+-------------------------------------------------------
 id                 | integer                     | not null default nextval('invoices_id_seq'::regclass)
 user_id            | integer                     |
 description        | character varying(255)      |
 deleted_at         | timestamp without time zone |
 created_at         | timestamp without time zone |
 updated_at         | timestamp without time zone |
 address_id         | integer                     |
 payment_method_id  | integer                     |
 charge_identifier  | character varying(255)      |
 delivery_id        | integer                     |
 service_credit_id  | integer                     |
 shipping_credit_id | integer                     |
Indexes:
    "invoices_pkey" PRIMARY KEY, btree (id)
    "index_invoices_on_delivery_id" btree (delivery_id)
    "index_invoices_on_user_id" btree (user_id)
 */
