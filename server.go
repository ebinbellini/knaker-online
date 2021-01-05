package main

import (
	"fmt"
	"log"
	"net/http"
	"path/filepath"
)

func main() {
	http.HandleFunc("/", serve)

	fmt.Println("Listening on :2987...")
	err := http.ListenAndServe(":2987", nil)
	if err != nil {
		log.Fatal(err)
	}
}

func serve(w http.ResponseWriter, r *http.Request) {
	url := filepath.Join("./", filepath.Clean(r.URL.Path))
	if len(url) == 1 {
		url = "knaker.html"
	}

	print("förstöker serveraa " + url + "\n")

	http.ServeFile(w, r, url)
}
