package controller

import (
	"fmt"
	"net/http"
	"strconv"

	"github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

// Get all merchandise items
func GetItems(c *gin.Context) {
	items, err := db.GetAllMerchItems(c.Request.Context())
	if err != nil {
		fmt.Println("ERROR", err.Error())
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch merchandise items"})
		return
	}
	c.JSON(http.StatusOK, items)
}

// Get a single merchandise item
func GetItem(c *gin.Context) {
	itemID, err := strconv.Atoi(c.Param("item_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID"})
		return
	}

	item, err := db.GetMerchItem(c.Request.Context(), itemID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Merchandise item not found"})
		return
	}

	c.JSON(http.StatusOK, item)
}

// Create an order
func CreateOrder(c *gin.Context) {
	userId, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}
	
	var order schema.Order
	if err := c.ShouldBindJSON(&order); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input"})
		return
	}

	order.UserID = userId
	
	fmt.Println("Order:", order)
	orderID, err := db.CreateOrder(c.Request.Context(), order)
	if err != nil {
		fmt.Println("ERROR", err.Error())
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create order"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Order created successfully", "order_id": orderID})
}

// Get user orders
func GetUserOrders(c *gin.Context) {
	userId, err := helpers.GetUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	orders, err := db.GetUserOrders(c.Request.Context(), userId)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, orders)
}
