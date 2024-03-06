package main

import (
	"context"
	"fmt"
	"math/rand"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"test/influxdb"
	"test/logger"
	"time"

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
	db := influxdb.New()

	// Simulate some work
	for {
		select {
		case <-ctx.Done():
			// When context is cancelled, stop the work
			fmt.Println("Context cancelled. Stopping work.")

			// Ensures background processes finishes
			db.Close()
			return

		default:
			// Wait for a while
			time.Sleep(100 * time.Millisecond)

			// Temperature 1
			writePoint(ctx, log, db, "temperature", "temp-device-1",
				"room-"+strconv.FormatInt(int64(randomizer.Intn(5)), 10))

			// Temperature 2
			writePoint(ctx, log, db, "temperature", "temp-device-2",
				"room-"+strconv.FormatInt(int64(randomizer.Intn(5)), 10))

			// Pressure 1
			writePoint(ctx, log, db, "pressure", "pres-device-1",
				"room-"+strconv.FormatInt(int64(randomizer.Intn(5)), 10))

			// Pressure 2
			writePoint(ctx, log, db, "pressure", "pres-device-2",
				"room-"+strconv.FormatInt(int64(randomizer.Intn(5)), 10))

			// Pressure 3
			writePoint(ctx, log, db, "pressure", "pres-device-3",
				"room-"+strconv.FormatInt(int64(randomizer.Intn(5)), 10))
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
) {

	value := randomizer.Intn(100)
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
