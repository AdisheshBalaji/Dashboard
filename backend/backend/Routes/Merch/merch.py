from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from Routes.Auth.cookie import get_user_id
from pydantic import BaseModel
from utils import conn
from queries.merch import *
from Routes.User.user import get_user

router = APIRouter(
    prefix="/api/merch",
    tags=["merch"],
)

class OrderCreate(BaseModel):
    merch_id: int
    size: str
    display_name: str
    vpa: str
    transaction_id: str

class OrderUpdate(BaseModel):
    status: bool

class StockUpdate(BaseModel):
    quantity: int

@router.get("/items")
def get_items():
    try:
        query = get_all_merch_items()
        cursor = conn.cursor()
        cursor.execute(query)
        items = cursor.fetchall()
        
        result = []
        for item in items:
            result.append({
                "id": item[0],
                "title": item[1],
                "deadline": item[2].isoformat(),
                "price": str(item[3]),
                "image_url": item[4],
                "description": item[5],
                "upi_id": item[6],
                "created_at": item[7].isoformat(),
            })
        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch merchandise items: {str(e)}"
        )

@router.get("/items/{item_id}")
def get_item(item_id: int):
    try:
        query = get_merch_item(item_id)
        cursor = conn.cursor()
        cursor.execute(query)
        item = cursor.fetchone()
        
        if not item:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Merchandise item with ID {item_id} not found"
            )
        
        return {
            "id": item[0],
            "title": item[1],
            "deadline": item[2].isoformat(),
            "price": str(item[3]),
            "image_url": item[4],
            "description": item[5],
            "upi_id": item[6],
            "created_at": item[7].isoformat(),
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch merchandise item: {str(e)}"
        )

@router.post("/order")
def create_order(order: OrderCreate, user_id: int = Depends(get_user_id)):
    try:
        valid_sizes = ['S', 'M', 'L', 'XL', 'XXL']
        if order.size not in valid_sizes:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid size. Must be one of: {', '.join(valid_sizes)}"
            )
            
        user = get_user(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        deadline_query = check_deadline_availability(order.merch_id)
        cursor = conn.cursor()
        cursor.execute(deadline_query)
        is_available = cursor.fetchone()[0]
        
        if not is_available:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Order deadline has passed"
            )
        
        item_query = get_merch_item(order.merch_id)
        cursor.execute(item_query)
        item_data = cursor.fetchone()
        
        if not item_data:
            raise HTTPException(status_code=404, detail="Merchandise item not found")
        
        order_query = insert_order_query(
            user_id, order.merch_id, order.size,
            order.transaction_id, order.display_name
        )
        cursor.execute(order_query)
        order_id = cursor.fetchone()[0]
        conn.commit()
        
        return {
            "message": "Order created successfully", 
            "order_id": order_id, 
            "transaction_id": order.transaction_id,
            "payment_status": "completed"
        }
    except HTTPException:
        conn.rollback()
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create order: {str(e)}"
        )

@router.get("/orders")
def list_user_orders(user_id: int = Depends(get_user_id)):
    """Get orders for the currently logged-in user"""
    try:
        user = get_user(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        query = get_user_orders(user_id)
        cursor = conn.cursor()
        cursor.execute(query)
        order_rows = cursor.fetchall()
        
        result = []
        for order in order_rows:
            result.append({
                "id": order[0],
                "merch_id": order[1],
                "title": order[2],
                "price": str(order[3]),
                "image_url": order[4],
                "size": order[5],
                "status": order[6],
                "order_date": order[7].isoformat() if order[7] else None,
                "transaction_id": order[8],
                "display_name": order[9]
            })
        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch user orders: {str(e)}"
        )