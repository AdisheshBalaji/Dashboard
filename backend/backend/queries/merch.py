from pypika import Query, Table, Order, functions as fn
from pypika.dialects import PostgreSQLQuery

merch = Table("merch")
orders = Table("orders")

def get_all_merch_items() -> str:
    query = Query.from_(merch).select(
        merch.id, merch.title, merch.deadline, merch.price,
        merch.image_url, merch.description, merch.upi_id, merch.created_at
    ).orderby(merch.id, order=Order.desc)
    return query.get_sql()

def get_merch_item(item_id: int) -> str:
    query = Query.from_(merch).select(
        merch.id, merch.title, merch.deadline, merch.price,
        merch.image_url, merch.description, merch.upi_id, merch.created_at
    ).where(merch.id == item_id)
    return query.get_sql()

def get_item_price(item_id: int) -> str:
    query = Query.from_(merch).select(
        merch.price
    ).where(merch.id == item_id)
    return query.get_sql()

def get_item_upi_id(item_id: int) -> str:
    query = Query.from_(merch).select(
        merch.upi_id
    ).where(merch.id == item_id)
    return query.get_sql()

def check_deadline_availability(merch_id: int) -> str:
    query = Query.from_(merch).select(
        merch.deadline > fn.Now()
    ).where(
        merch.id == merch_id
    )
    return query.get_sql()

def insert_order_query(user_id: int, merch_id: int, size: str, transaction_id: str, display_name: str) -> str:
    query = PostgreSQLQuery.into(orders).columns(
        orders.user_id, orders.merch_id, orders.size, 
        orders.transaction_id, orders.display_name,
        orders.status, orders.order_date
    ).insert(
        user_id, merch_id, size, transaction_id, display_name,
        False, fn.Cast(fn.Now(), 'DATE')
    ).returning(orders.id)
    return query.get_sql()

def get_user_orders(user_id: int) -> str:
    query = Query.from_(orders).join(
        merch
    ).on(
        orders.merch_id == merch.id
    ).select(
        orders.id, orders.merch_id, merch.title, merch.price, 
        merch.image_url, orders.size, orders.status, orders.order_date,
        orders.transaction_id, orders.display_name
    ).where(
        orders.user_id == user_id
    )
    return query.get_sql()