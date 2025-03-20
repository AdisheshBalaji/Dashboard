package controller

import (
	"encoding/json"
	"fmt"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"io"
	"net/http"
	"os"
	"slices"
	"strconv"
	"strings"

	"github.com/LambdaIITH/Dashboard/backend/internal/db"
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
	var announcement schema.RequestAnnouncement
	if c.Bind(&announcement) != nil {
		fmt.Println("ERROR: Post Announcement Data could not bind")
		return
	}

	{
		filterFile, _ := os.Open("announcementFilters.json")
		defer filterFile.Close()
		fileData, _ := io.ReadAll(filterFile)
		var tags []string
		json.Unmarshal(fileData, &tags)

		for idx, tag := range announcement.Tags {
			announcement.Tags[idx] = strings.ToUpper(tag[0:1]) + strings.ToLower(tag[1:])
			if !slices.Contains(tags, announcement.Tags[idx]) {
				c.Status(http.StatusBadRequest)
				fmt.Println("ERROR: Non Existent Tag")
				return
			}

		}
	}

	img, err := announcement.Image.Open()
	if err != nil {
		fmt.Println("ERROR: Could not open image")
		c.Status(http.StatusBadRequest)
		return
	}

	_, format, err := image.DecodeConfig(img)
	if err != nil {
		fmt.Println("ERROR: Corrupt Image Data")
		c.Status(http.StatusBadRequest)
		return
	}

	id, err := db.PostAnnouncementToDB(c, &announcement)
	if err != nil {
		fmt.Println("ERROR: PostAnnouncement Call to DB")
		c.Status(http.StatusBadRequest)
		return
	}

	fileName := strconv.Itoa(id) + "." + format
	if _, err := os.Stat("announcementImages/"); err != nil {
		err := os.Mkdir("announcementImages/", 0777)

		if err != nil {
			fmt.Println("Error: Could not make directory to save announcement Images")
			return
		}
	}

	img.Seek(0, io.SeekStart)
	imgBytes, _ := io.ReadAll(img)

	err = os.WriteFile("announcementImages/"+fileName, imgBytes, 0777)
	fmt.Println(fileName)
	if err != nil {
		fmt.Println("Error: Saving Image to Disk")
		c.Status(http.StatusBadRequest)
		db.DeleteAnnouncementFromDB(c, id)
		return
	}

	c.Status(http.StatusOK)
}

func GetAnnouncementsFilters(c *gin.Context) {
	filters, _ := os.Open("announcementFilters.json")
	defer filters.Close()
	fileData, _ := io.ReadAll(filters)

	c.JSON(http.StatusOK, string(fileData))
}
