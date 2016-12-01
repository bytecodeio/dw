import time

def fix_dates(event):  
  if 'custom_1' in event:
    try:
      event['custom_1'] = time.strftime("%Y-%m-%d",time.strptime(event['custom_1'], "%Y-%m-%d"))
    except ValueError:
      #date is invalid
      del event['custom_1']
  if 'custom' in event and 'day' in event['custom']:
    try:
      event['custom']['day'] = time.strftime("%Y-%m-%d",time.strptime(event['custom']['day'], "%Y-%m-%d"))  
    except ValueError:
      #date is invalid
      del event['custom']['day']

def transform(event):
  if event['_metadata']['input_label'].startswith('pg_'):
    event['_metadata']['event_type'] = event['_metadata']['input_label']
  if event['_metadata']['input_label'] == "pg_service_credits" or event['_metadata']['input_label'] == "pg_shipping_credits":
    if 'refunded_from_invoice' in event['metadata'] and event['metadata']['refunded_from_invoice'] != "":
      string_rfi = ",".join(map(str,event['metadata']['refunded_from_invoice']))
      event['metadata']['refunded_from_invoice'] = string_rfi
  if 'admin_tags' in event:
    string_admin_tags = ",".join(event['admin_tags'])
    event['admin_tags'] = string_admin_tags
  if 'search_alerts' in event:
    string_search_alerts = ",".join(event['search_alerts'])
    event['search_alerts'] = string_search_alerts
  if 'categories' in event:
    string_categories = ",".join(event['categories'])
    event['categories'] = string_categories
  if 'sections' in event:
    string_sections = ",".join(event['sections'])
    event['sections'] = string_sections
  if 'metadata' in event and event['metadata'] is not None and 'promo_code' in event['metadata']:
    if not type(event['metadata']['promo_code']) == dict:
      event['metadata']['promo_code'] = {
        'promo_code': event['metadata']['promo_code']
        }
  if 'fulfillment_options' in event:
    string_fulfillment_options = ",".join(event['fulfillment_options'])
    event['fulfillment_options'] = string_fulfillment_options
  if 'screen_flow' in event:
    string_screen_flow = ",".join(event['screen_flow'])
    event['screen_flow'] = string_screen_flow
    
  fix_dates(event)
  
  # 6/24/106: Type conversion error for localytics_ios.custome_credit_amount, localytics_ios.custom_id. This INT field conversion fails when it has an empty string like this: "<null>" 
  if 'input_label' in event['_metadata'] and event['_metadata']['input_label'] == 'localytics-ios' and 'custom' in event:
    if 'credit_amount' in event['custom'] and  event['custom']['credit_amount'] == "<null>":
        event['custom']['credit_amount'] = None
    if 'id' in event['custom'] and  event['custom']['id'] == "<null>":
        event['custom']['id'] = None
  # 6/24/2016: Type conversion error: string value present in custom_3 which is an INT.       
  if 'input_label' in event['_metadata'] and event['_metadata']['input_label'] == 'localytics-ios' and 'custom_3' in event:
    if not (event['custom_3'].isdigit()):
      event['custom_3'] = None
  # 6/23/106: Add the 'None' condition after Transform Function errors. 
  if 'input_label' in event['_metadata'] and event['_metadata']['input_label'] == 'Segment_Webhook' and 'properties' in event and event['properties'] != None and 'seconds_since_joined' in event['properties']:
    seconds_rounded = round(event['properties']['seconds_since_joined'])
    event['properties']['seconds_since_joined'] = seconds_rounded
  if 'input_label' in event['_metadata'] and event['_metadata']['input_label'] == 'keen-onetime-reload':
    if 'seconds_since_joined' in event:
      seconds_rounded = round(event['seconds_since_joined'])
      event['seconds_since_joined'] = seconds_rounded
    if 'seconds_since_transaction' in event:
      event['seconds_since_transaction'] = round(event['seconds_since_transaction'])
    if 'seconds_since_last_visit' in event:
      event['seconds_since_last_visit'] = round(event['seconds_since_last_visit'])
    if 'seconds_since_first_win' in event:
      event['seconds_since_first_win'] = round(event['seconds_since_first_win'])
    if 'user_credit_contribution' in event:
      event['user_credit_contribution'] = round(float(event['user_credit_contribution']))

  if 'input_label' in event['_metadata'] and event['_metadata']['input_label'] == 'keen-onetime-reload' and 'experiments' in event and event['experiments'] is not None:
    string_experiment = ",".join(event['experiments'])
    event['experiments'] = string_experiment
  if 'input_label' in event['_metadata'] and event['_metadata']['input_label'] == 'keen-onetime-reload' and 'credit_price' in event:
    num_credit_price = int(round(float(event['credit_price'])))
    event['credit_price'] = num_credit_price
  if 'input_label' in event['_metadata'] and event['_metadata']['input_label'] == 'keen-onetime-reload' and 'yrd_price' in event:
    float_yrd_price = float(event['yrd_price'])
    event['yrd_price'] = float_yrd_price
  
  # Discard REST events
  # if event['_metadata']['input_label'] == 'REST_Endpoint':
  #  return None
  return event