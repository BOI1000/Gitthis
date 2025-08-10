#!/usr/bin/env python3
from datetime import datetime, timedelta
import sys

def main(start_year: int, end_year: int) -> int:
    start_date = datetime(start_year, 1, 1)
    end_date = datetime(end_year, 12, 31)
    delta = timedelta(days=1)
    
    while start_date <= end_date:
        print(start_date.strftime("%Y-%m-%d"))
        start_date += delta
    return 0

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage:", sys.argv[0], "<year> <year>")
        sys.exit(1)

    try:
        year1 = int(sys.argv[1])
        year2 = int(sys.argv[2])
    except ValueError:
        print("Please enter valid years.")
        sys.exit(1)
    
    main(year1, year2)