from pypika import Query, Table, Order, functions as fn
from pypika.dialects import PostgreSQLQuery

merch = Table("merch")
merch_sizes = Table("merch_sizes")
merch_images = Table("merch_images")
orders = Table("orders")

def get_all_merch_items() -> str:
    query = Query.from_(merch).select(
        merch.id, merch.title, merch.deadline, merch.price,
        merch.image_url, merch.description, merch.upi_id, merch.created_at,
        merch.is_oversized, merch.size_guide_url, merch.ask_display_name
    ).orderby(merch.id, order=Order.desc)
    return query.get_sql()

def get_merch_sizes(merch_id: int = None) -> str:
    query = Query.from_(merch_sizes).select(
        merch_sizes.id, merch_sizes.merch_id, merch_sizes.size_name, merch_sizes.created_at
    )
    if merch_id is not None:
        query = query.where(merch_sizes.merch_id == merch_id)
    return query.get_sql()

def get_merch_images(merch_id: int = None) -> str:
    query = Query.from_(merch_images).select(
        merch_images.merch_id, merch_images.image_url
    )
    if merch_id is not None:
        query = query.where(merch_images.merch_id == merch_id)
    
    return query.get_sql()

def get_merch_item(item_id: int) -> str:
    query = Query.from_(merch).select(
        merch.id, merch.title, merch.deadline, merch.price,
        merch.image_url, merch.description, merch.upi_id, merch.created_at,
        merch.is_oversized, merch.size_guide_url, merch.ask_display_name
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

def insert_order_query(user_id: int, merch_id: int, size: str, transaction_id: str, display_name: str, is_oversized: bool = False) -> str:
    query = PostgreSQLQuery.into(orders).columns(
        orders.user_id, orders.merch_id, orders.size, 
        orders.transaction_id, orders.display_name,
        orders.status, orders.order_date, orders.is_oversized
    ).insert(
        user_id, merch_id, size, transaction_id, display_name,
        False, fn.Cast(fn.Now(), 'DATE'), is_oversized
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
        orders.transaction_id, orders.display_name, orders.is_oversized
    ).where(
        orders.user_id == user_id
    )
    return query.get_sql()