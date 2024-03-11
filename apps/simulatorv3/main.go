package main

import (
	"context"
	"fmt"
	"math/rand"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"simulatorv3/influxdb"
	"simulatorv3/logger"

	"github.com/sirupsen/logrus"
)

var randomizer *rand.Rand

func init() {
	randomizer = rand.New(rand.NewSource(time.Now().UnixNano()))
}

func main() {
	// Init context
	ctx, cancel := context.WithCancel(context.Background())

	// Channel to notify on SIGTERM signal
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGTERM)
	go func() {
		<-sigCh
		fmt.Println("Received SIGTERM, shutting down gracefully...")
		cancel()
	}()

	// Instantiate logger
	log := logger.NewLogger()

	// Instantiate InfluxDB
	db, err := influxdb.New()
	if err != nil {
		panic(err)
	}
	defer db.Close()

	// Write points
	for {
		// Simulate some work
		for {
			select {
			case <-ctx.Done():
				// When context is cancelled, stop the work
				fmt.Println("Context cancelled. Stopping work.")
				return

			default:
				// Set tags
				environment := "env-" + strconv.FormatInt(int64(randomizer.Intn(5)), 10)
				device := "dev-" + strconv.FormatInt(int64(randomizer.Intn(3)), 10)

				// Set field
				value := randomizer.Intn(100)

				// Write point
				writePoint(ctx, log, db, "test", device, environment, value)

				time.Sleep(1 * time.Second)
			}
		}
	}
}

func writePoint(
	ctx context.Context,
	log *logger.Logger,
	db *influxdb.InfluxDb,
	measurementName string,
	deviceName string,
	environmentName string,
	value int,
) {

	attrs := map[string]interface{}{
		"device":      deviceName,
		"environment": environmentName,
		"value":       value,
	}

	log.Log(logrus.InfoLevel, "Writing point...", attrs)
	err := db.WritePoint(ctx, measurementName,
		map[string]string{
			"device":      deviceName,
			"environment": environmentName,
		},
		map[string]interface{}{
			"value": value,
		},
	)
	if err != nil {
		attrs["error"] = err.Error()
		log.Log(logrus.ErrorLevel, "Writing point is failed.", attrs)
	}
}
