from datetime import datetime
import uuid
from sqlalchemy import (
    Column, String, Integer, Float, Boolean, DateTime, Text, ForeignKey
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()

class UserDevice(Base):
    __tablename__ = 'users_devices'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    device_id = Column(String(64), unique=True, nullable=False, index=True)
    mummy_name = Column(String(100), default="Mummy")
    son_phone_number = Column(String(20), nullable=False)
    primary_language = Column(String(10), default="gu-IN")
    miui_autostart_enabled = Column(Boolean, default=True)
    battery_saver_excluded = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    telemetry_logs = relationship("TelemetryReport", back_populates="device", cascade="all, delete-orphan")
    security_alerts = relationship("SecurityAlert", back_populates="device", cascade="all, delete-orphan")
    emergency_alerts = relationship("EmergencyAlert", back_populates="device", cascade="all, delete-orphan")
    medication_logs = relationship("MedicationLog", back_populates="device", cascade="all, delete-orphan")


class TelemetryReport(Base):
    __tablename__ = 'telemetry_reports'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    device_id = Column(String(64), ForeignKey('users_devices.device_id'), nullable=False, index=True)
    battery_level = Column(Integer, nullable=False)
    is_charging = Column(Boolean, default=False)
    network_type = Column(String(20), default="4G")
    blocked_threats_today = Column(Integer, default=0)
    medication_status = Column(Text, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)

    device = relationship("UserDevice", back_populates="telemetry_logs")


class SecurityAlert(Base):
    __tablename__ = 'security_alerts'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    device_id = Column(String(64), ForeignKey('users_devices.device_id'), nullable=False, index=True)
    threat_type = Column(String(50), nullable=False)
    sender_id = Column(String(50), nullable=False)
    message_snippet = Column(Text, nullable=True)
    action_taken = Column(String(50), default="BLOCKED_AND_NOTIFIED")
    notified_contact = Column(String(20), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)

    device = relationship("UserDevice", back_populates="security_alerts")


class EmergencyAlert(Base):
    __tablename__ = 'emergency_alerts'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    device_id = Column(String(64), ForeignKey('users_devices.device_id'), nullable=False, index=True)
    emergency_type = Column(String(50), nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    battery_level = Column(Integer, nullable=False)
    audio_clip_url = Column(String(255), nullable=True)
    status = Column(String(20), default="DISPATCHED", index=True)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)

    device = relationship("UserDevice", back_populates="emergency_alerts")


class MedicationLog(Base):
    __tablename__ = 'medication_logs'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    device_id = Column(String(64), ForeignKey('users_devices.device_id'), nullable=False, index=True)
    medication_id = Column(String(50), nullable=False)
    medication_name = Column(String(100), nullable=False)
    scheduled_time = Column(DateTime, nullable=False)
    status = Column(String(20), nullable=False)
    taken_with_notes = Column(String(100), nullable=True)
    snooze_minutes = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)

    device = relationship("UserDevice", back_populates="medication_logs")


class AppRelease(Base):
    __tablename__ = 'app_releases'

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    version = Column(String(20), unique=True, nullable=False, index=True)
    min_app_version = Column(String(20), nullable=False)
    apk_url = Column(String(255), nullable=False)
    mandatory_update = Column(Boolean, default=False)
    release_notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)