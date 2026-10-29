import csv
import random
from datetime import date, timedelta
from pathlib import Path

random.seed(42)
OUT = Path("data/baserow")
OUT.mkdir(parents=True, exist_ok=True)

COUNTRIES = ["India", "UAE", "USA", "UK", "Germany", "Singapore", "Canada"]
FIRST = ["Aarav", "Maya", "Liam", "Noor", "Sofia", "Omar", "Priya", "Ethan", "Zara", "Kabir", "Emma", "Yusuf"]
LAST = ["Sharma", "Khan", "Smith", "Patel", "Müller", "Tan", "Brown", "Ali", "Nair", "Singh"]
CATEGORIES = {"Electronics": (20, 400), "Home": (5, 120), "Books": (4, 40), "Sports": (10, 150), "Beauty": (6, 80)}
STATUSES = ["Delivered", "Shipped", "Pending", "Cancelled", "Returned"]

# customers
customers = []
for i in range(1, 151):
    name = f"{random.choice(FIRST)} {random.choice(LAST)}"
    email = f"{name.lower().replace(' ', '.')}{i}@example.com"
    country = random.choice(COUNTRIES)
    signup = date.today() - timedelta(days=random.randint(30, 700))
    customers.append([f"C{i:04d}", name, email, country, signup.isoformat(), random.choice(["true", "true", "true", "false"])])
for row in random.sample(customers, 5):          # duplicates with different casing
    dup = row.copy()
    dup[0] = f"C{len(customers) + 1:04d}"
    dup[2] = dup[2].upper()
    customers.append(dup)
for row in random.sample(customers, 6):          # missing countries
    row[3] = ""

# products
products = []
for i in range(1, 31):
    cat = random.choice(list(CATEGORIES))
    lo, hi = CATEGORIES[cat]
    products.append([f"P{i:03d}", f"{cat} Item {i}", cat, round(random.uniform(lo, hi), 2)])

# orders
orders = []
for i in range(1, 2001):
    status = random.choices(STATUSES, weights=[55, 20, 10, 10, 5])[0]
    if random.random() < 0.08:                    # inconsistent spelling
        status = random.choice([status.lower(), status.upper()])
    qty = random.randint(1, 5)
    if random.random() < 0.01:                    # bad quantities
        qty = random.choice([0, -1])
    odate = date.today() - timedelta(days=random.randint(0, 89))
    orders.append([f"O{i:05d}", random.choice(customers)[0], random.choice(products)[0],
                   qty, odate.isoformat(), status, random.choice([0, 0, 0, 5, 10, 15])])

def write(name, header, rows):
    with open(OUT / name, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
    print(f"{name}: {len(rows)} rows")

write("customers.csv", ["customer_code", "full_name", "email", "country", "signup_date", "is_active"], customers)
write("products.csv", ["product_code", "product_name", "category", "unit_price"], products)
write("orders.csv", ["order_code", "customer_code", "product_code", "quantity", "order_date", "status", "discount_pct"], orders)