package main

import (
	"fmt"
	rbt "github.com/go-vgo/robotgo"
)

func main() {
	fmt.Println("Welcome to segue!")
	fmt.Println("This is a simple Go application that uses robotgo to interact with the system.")

	fmt.Printf("Main pid: %d\n", rbt.GetMainId())
}
