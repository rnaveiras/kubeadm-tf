package main

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
)

const (
	TokenIDLen = 6
	TokenBytes = 8
)

func RandBytes(length int) ([]byte, string, error) {
	b := make([]byte, length)
	_, err := rand.Read(b)
	if err != nil {
		return nil, "", err
	}
	// It's only the tokenID that doesn't care about raw byte slice,
	// so we just encoded it in place and ignore bytes slice where we
	// do not want it
	return b, hex.EncodeToString(b), nil
}

func main() {
	_, tokenID, err := RandBytes(TokenIDLen / 2)
	if err != nil {
		return
	}

	_, token, err := RandBytes(TokenBytes)
	if err != nil {
		return
	}

	t := fmt.Sprintf("%s.%s", tokenID, token)
	fmt.Printf("token: %s\n", t)
}
