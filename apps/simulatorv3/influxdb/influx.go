package influxdb

import (
	"context"
	"fmt"
	"os"

	"github.com/InfluxCommunity/influxdb3-go/influxdb3"
)

type InfluxDb struct {
	client *influxdb3.Client
}

func New() (
	*InfluxDb,
	error,
) {

	influxUrl := os.Getenv("INFLUXDB_ADDRESS")
	influxToken := os.Getenv("INFLUXDB_TOKEN")
	influxBucket := os.Getenv("INFLUXDB_BUCKET")

	client, err := influxdb3.New(influxdb3.ClientConfig{
		Host:     influxUrl,
		Token:    influxToken,
		Database: influxBucket,
	})

	if err != nil {
		return nil, err
	}

	influxdb := &InfluxDb{
		client: client,
	}
	return influxdb, nil
}

func (i *InfluxDb) WritePoint(
	ctx context.Context,
	measurementName string,
	tags map[string]string,
	fields map[string]interface{},
) error {

	// Create point
	point := influxdb3.NewPointWithMeasurement(measurementName)

	// Set tags
	for k, v := range tags {
		point.SetTag(k, v)
	}

	// Set fields
	for k, v := range fields {
		point.SetField(k, v)
	}

	// Write point
	err := i.client.WritePoints(
		ctx, []*influxdb3.Point{point})
	if err != nil {
		fmt.Println(err)
		return err
	}
	return nil
}

func (i *InfluxDb) Close() {
	// Ensures background processes finishes
	i.client.Close()
}
