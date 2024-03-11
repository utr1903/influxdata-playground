package influxdb

import (
	"context"
	"os"
	"time"

	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	api "github.com/influxdata/influxdb-client-go/v2/api"
)

type InfluxDb struct {
	client   influxdb2.Client
	writeApi api.WriteAPIBlocking
}

func New() *InfluxDb {
	influxUrl := os.Getenv("INFLUXDB_ADDRESS")
	influxToken := os.Getenv("INFLUXDB_TOKEN")
	influxOrg := os.Getenv("INFLUXDB_ORGANIZATION")
	influxBucket := os.Getenv("INFLUXDB_BUCKET")

	client := influxdb2.NewClient(influxUrl, influxToken)
	writeApi := client.WriteAPIBlocking(influxOrg, influxBucket)

	return &InfluxDb{
		client:   client,
		writeApi: writeApi,
	}
}

func (i *InfluxDb) WritePoint(
	ctx context.Context,
	measurementName string,
	tags map[string]string,
	fields map[string]interface{},
) error {

	// Create point
	p := influxdb2.NewPoint(
		measurementName,
		tags,
		fields,
		time.Now(),
	)

	// Write point
	return i.writeApi.WritePoint(ctx, p)
}

func (i *InfluxDb) Close() {
	// Ensures background processes finishes
	i.client.Close()
}
