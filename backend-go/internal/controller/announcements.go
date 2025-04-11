package controller

import (
	"encoding/json"
	"fmt"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"slices"
	"strconv"
	"strings"

	"github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

func GetAnnouncements(c *gin.Context) {
	limit, err := strconv.Atoi(c.Query("limit"))
	if err != nil {
		c.Status(http.StatusBadRequest)
		return
	}

	offset, err := strconv.Atoi(c.Query("offset"))
	if err != nil {
		c.Status(http.StatusBadRequest)
		return
	}
	if limit == 0 {
		c.Status(http.StatusBadRequest)
		return
	}
	announcements, _ := db.GetAnnouncementsFromDB(c, limit, offset)
	c.JSON(http.StatusOK, announcements)
}

func PostAnnouncement(c *gin.Context) {
	var announcement schema.AnnouncementRequest
	if c.Bind(&announcement) != nil {
		fmt.Println("ERROR: Post Announcement Data could not bind")
		c.Status(http.StatusBadRequest)
		return
	}

	{
		tagsAndCategoryFile, _ := os.Open("announcementTandC.json")
		defer tagsAndCategoryFile.Close()
		fileData, _ := io.ReadAll(tagsAndCategoryFile)
		var fileJson map[string][]string
		json.Unmarshal(fileData, &fileJson)

		for idx, tag := range announcement.Tags {
			announcement.Tags[idx] = strings.ToUpper(tag[0:1]) + strings.ToLower(tag[1:])
			if !slices.Contains(fileJson["tags"], announcement.Tags[idx]) {
				c.Status(http.StatusBadRequest)
				fmt.Println("ERROR: Non Existent Tag")
				return
			}
		}

		for idx, category := range announcement.Category {
			announcement.Category[idx] = strings.ToUpper(category[0:1]) + strings.ToLower(category[1:])
			if !slices.Contains(fileJson["category"], announcement.Category[idx]) {
				c.Status(http.StatusBadRequest)
				fmt.Println("ERROR: Non Existent Category")
				return
			}
		}
	}

	id, err := db.PostAnnouncementToDB(c, &announcement)
	if err != nil {
		fmt.Println("ERROR: PostAnnouncement Call to DB")
		c.Status(http.StatusBadRequest)
		return
	}

	s3Client := helpers.NewS3Client(os.Getenv("BUCKET_NAME"), os.Getenv("REGION"), os.Getenv("RESOURCE_URI"))

	imagePaths, err := s3Client.UploadImages([]*multipart.FileHeader{announcement.Image}, id, "announcement")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload images"})
		return
	}

	if err = db.AddAnnouncementImageURIToDB(c, id, imagePaths[0]); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"Error": "Could not update DB with image uri"})
		fmt.Println("ERROR: Could not update DB with image URI")
		db.DeleteAnnouncementFromDB(c, id)
		return
	}

	c.Status(http.StatusOK)
}

func GetAnnouncementsTandC(c *gin.Context) {
	filters, _ := os.Open("announcementTandC.json")
	defer filters.Close()
	fileData, _ := io.ReadAll(filters)

	c.JSON(http.StatusOK, string(fileData))
}
