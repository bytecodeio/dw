"""
Write insert statements for every minute between the given date range
and for the given table name,
This creates a static "minute" dimension table for data warehouse.
For example:
INSERT INTO minute_dim ('2012-01-01 00:00:00');
INSERT INTO minute_dim ('2012-01-01 00:01:00');
INSERT INTO minute_dim ('2012-01-01 00:02:00');
"""

import argparse, sys
from datetime import datetime, timedelta

"""
  rangedelta:
  Get the continuous datetime strings between the start-end range, and incremented by the given delta
"""
def rangedelta(start, end, delta):
    curr = start
    while curr < end:
        yield curr
        curr += delta
"""
  valid_date:
  Convert the string into a valid datetime object
"""
def valid_date(s):
    try:
        return datetime.strptime(s, "%Y%m%d")
    except ValueError:
        msg = "Not a valid date: '{0}'.".format(s)
        raise argparse.ArgumentTypeError(msg)


parser = argparse.ArgumentParser()
parser.add_argument('-t', '--table_name', required=True, action="store", dest="table_name", help='Table to insert the data in.' )
parser.add_argument('-s', '--start_date', required=True, type=valid_date, action="store", dest="start_date", help='Start Date in format YYYYMMDD.' )
parser.add_argument('-e', '--end_date', required=True, type=valid_date, action="store", dest="end_date", help='End Date in format YYYYMMDD.' )

args = parser.parse_args()

if (args.end_date < args.start_date):
    parser.print_help()
    print ("-e/--end_date: should be >= -s/--start_date.")
    sys.exit(1)


start_date = args.start_date
# NOTE: Go to the fnext day to print the last minute of the previous day
end_date = args.end_date + timedelta(days=1)


for result in rangedelta( start_date, end_date, timedelta(minutes=1)):
    print("INSERT INTO " + args.table_name + " (\'" + result.strftime('%Y-%m-%d %H:%M:%S') + "\'); \n" );

