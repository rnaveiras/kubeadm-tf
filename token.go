package main

// Extracted from https://github.com/kubernetes/kubernetes/blob/master/cmd/kubeadm/app/util/tokens.go

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
	fmt.Printf("%s", t)
}
