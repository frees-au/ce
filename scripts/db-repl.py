#!/usr/bin/env python3
import sqlite3
import sys

db = sqlite3.connect(sys.argv[1])
db.row_factory = sqlite3.Row

db.create_collation(
    "NOCASE_UTF8",
    lambda a, b: (a.casefold() > b.casefold()) - (a.casefold() < b.casefold())
)

print(f"Connected to {sys.argv[1]}")
print("Enter SQL statements, or .quit to exit.")

while True:
    try:
        sql = input("sqlite> ").strip()

        if sql in (".quit", ".exit"):
            break

        if not sql:
            continue

        cursor = db.execute(sql)

        if cursor.description:
            for row in cursor:
                print(tuple(row))
        else:
            db.commit()
            print(f"{cursor.rowcount} rows affected")

    except (sqlite3.Error, EOFError, KeyboardInterrupt) as e:
        if isinstance(e, (EOFError, KeyboardInterrupt)):
            break
        print(f"Error: {e}")

db.close()
