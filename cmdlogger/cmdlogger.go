package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"os"
	"os/user"
	"path/filepath"
	"strings"
	"time"

	shellquote "github.com/kballard/go-shellquote"
)

type Item struct {
	Date string `json:"date"`
	Host string `json:"host"`
	User string `json:"user"`
	Dir  string `json:"dir"`
	Cmd  string `json:"cmd"`
}

func Contains(k string, s []string) bool {
	for _, v := range s {
		if k == v {
			return true
		}
	}
	return false
}

func LogCmd(historyFile string) {
	argv := os.Args[2:]
	var cmd string
	if len(argv) > 1 {
		cmd = strings.TrimSpace(shellquote.Join(argv...))
	} else {
		cmd = strings.TrimSpace(argv[0])
	}

	ignoreCmds := strings.Split(os.Getenv("CMDLOG_IGNORES"), " ")
	if Contains(strings.Split(cmd, " ")[0], ignoreCmds) {
		return
	}

	date := time.Now().Format("2006-01-02 15:04:05")
	host, _ := os.Hostname()
	username, _ := user.Current()
	dir, _ := os.Getwd()
	item := Item{date, host, username.Username, dir, cmd}

	f, err := os.OpenFile(historyFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Println(err)
	}
	defer f.Close()

	encoder := json.NewEncoder(f)
	encoder.Encode(item)
}

func ParseItems(historyFile string) []Item {
	f, err := os.Open(historyFile)
	if errors.Is(err, os.ErrNotExist) {
		f, err = os.OpenFile(historyFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
		f.Close()
		f, err = os.Open(historyFile)
	}
	defer f.Close()
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}
	var items []Item

	// Parse JSONL
	decoder := json.NewDecoder(f)
	for {
		var item Item
		err := decoder.Decode(&item)
		if err == io.EOF {
			break
		}
		if dir, _ := os.Getwd(); item.Dir == dir {
			items = append(items, item)
		}
	}
	return items
}

func LookupHistory(historyFile string) {
	items := ParseItems(historyFile)
	// Deduplicate history
	seen := make(map[string]bool)
	size := len(items)
	for i := size - 1; i >= 0; i-- {
		item := items[i]
		cmd := item.Cmd
		if seen[cmd] {
			continue
		} else {
			fmt.Printf("%s%s", cmd, string([]byte{0}))
			seen[cmd] = true
		}
	}
}

func PrintHistory(historyFile string) {
	items := ParseItems(historyFile)
	// Print history
	size := len(items)
	for i := size - 1; i >= 0; i-- {
		item := items[i]
		cmd := strings.ReplaceAll(item.Cmd, "\n", "\\n")
		fmt.Printf("%5d %s %s\n", i+1, item.Date, cmd)
	}
}

func UniqueHistory(historyFile string) {
	items := ParseItems(historyFile)
	// Deduplicate entries
	var uniqItems []Item
	seen := make(map[string]bool)
	size := len(items)
	for i := size - 1; i >= 0; i-- {
		item := items[i]
		cmd := item.Cmd
		if seen[cmd] {
			continue
		} else {
			uniqItems = append(uniqItems, item)
			seen[cmd] = true
		}
	}

	// Print history
	uniqSize := len(uniqItems)
	for i := 0; i < uniqSize; i++ {
		item := uniqItems[i]
		cmd := strings.ReplaceAll(item.Cmd, "\n", "\\n")
		fmt.Printf("%5d %s %s\n", uniqSize-i, item.Date, cmd)
	}
}

func Help() {
	fmt.Println(
		`cmdlogger [-a CMD...|-l|-p|-u]

    -a CMD...  Log the command.
    -l         Look up history of the current directory.
    -p         Print history of the current directory.
    -u         Print unique history of the current directory.
`)
	os.Exit(1)
}

func main() {
	if len(os.Args) <= 1 {
		Help()
	}

	historyFile := os.Getenv("CMDLOG_HISTORY_FILE")
	if historyFile == "" {
		home, _ := os.UserHomeDir()
		historyFile = filepath.Join(home, ".cmdlog_history")
	}

	opt := os.Args[1]
	if opt == "-a" {
		if os.Getenv("DISABLE_CMDLOG") == "" {
			LogCmd(historyFile)
		}
	} else if opt == "-l" {
		LookupHistory(historyFile)
	} else if opt == "-p" {
		PrintHistory(historyFile)
	} else if opt == "-u" {
		UniqueHistory(historyFile)
	} else {
		Help()
	}
}
