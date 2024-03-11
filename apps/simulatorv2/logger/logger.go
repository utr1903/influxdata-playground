package logger

import (
	"github.com/sirupsen/logrus"
)

type Logger struct {
	logger *logrus.Logger
}

// Creates new logger
func NewLogger() *Logger {
	l := logrus.New()
	l.SetLevel(logrus.InfoLevel)
	l.SetFormatter(&logrus.JSONFormatter{})
	return &Logger{
		logger: l,
	}
}

// Logs a message with attributes
func (l *Logger) Log(
	lvl logrus.Level,
	msg string,
	attrs map[string]interface{},
) {

	fields := logrus.Fields{}

	// Put specific attributes
	for key, val := range attrs {
		fields[key] = val
	}

	l.logger.WithFields(fields).Log(lvl, msg)
}
