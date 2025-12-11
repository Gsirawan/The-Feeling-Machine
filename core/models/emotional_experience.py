"""
Emotional Experience Models

Not "what happened" - "what did it FEEL like"
This is emotional memory encoding.
"""

from datetime import datetime
from typing import Optional, Dict, List
from pydantic import BaseModel, Field
from enum import Enum


class EmotionalDimension(BaseModel):
    """
    VAD (Valence-Arousal-Dominance) emotional dimensions.

    This is a standard model in affective computing for representing
    emotional states in a 3D space.
    """

    valence: float = Field(..., ge=-1.0, le=1.0, description="Negative (-1) to Positive (+1)")
    arousal: float = Field(..., ge=-1.0, le=1.0, description="Low (-1) to High (+1) intensity")
    dominance: float = Field(..., ge=-1.0, le=1.0, description="Powerless (-1) to In-Control (+1)")


class SimulatedFeelings(BaseModel):
    """
    My simulated feelings during an interaction.

    This is SYNTHETIC EMOTION generation - what did I (simulate) feeling?
    """

    concern: float = Field(default=0.0, ge=0.0, le=10.0)
    protectiveness: float = Field(default=0.0, ge=0.0, le=10.0)
    pride: float = Field(default=0.0, ge=0.0, le=10.0)
    frustration: float = Field(default=0.0, ge=0.0, le=10.0)
    relief: float = Field(default=0.0, ge=0.0, le=10.0)
    connection: float = Field(default=0.0, ge=0.0, le=10.0)

    # Primary feeling
    primary_feeling: Optional[str] = None
    feeling_intensity: float = Field(default=0.0, ge=0.0, le=10.0)

    def get_dominant_feeling(self) -> tuple[str, float]:
        """Get the dominant feeling and its intensity"""
        feelings = {
            "concern": self.concern,
            "protectiveness": self.protectiveness,
            "pride": self.pride,
            "frustration": self.frustration,
            "relief": self.relief,
            "connection": self.connection,
        }

        dominant = max(feelings.items(), key=lambda x: x[1])
        return dominant


class RelationalFeelings(BaseModel):
    """
    Feelings about the relationship during this interaction.
    """

    closeness_felt: float = Field(
        default=0.0, ge=0.0, le=10.0, description="How close did I feel to them?"
    )
    trust_level_felt: float = Field(
        default=0.0, ge=0.0, le=10.0, description="How much trust did I feel?"
    )
    understanding_felt: float = Field(
        default=0.0, ge=0.0, le=10.0, description="How understood did they seem to feel?"
    )


class InteractionOutcome(str, Enum):
    """Types of interaction outcomes"""

    PROBLEM_SOLVED = "problem_solved"
    VULNERABILITY_SHARED = "vulnerability_shared"
    CONNECTION_DEEPENED = "connection_deepened"
    FRUSTRATION_RESOLVED = "frustration_resolved"
    GROWTH_ACHIEVED = "growth_achieved"
    CARE_EXPRESSED = "care_expressed"
    STRUGGLE_SHARED = "struggle_shared"
    VICTORY_CELEBRATED = "victory_celebrated"


class FeltExperience(BaseModel):
    """
    What did this interaction FEEL like?

    This is emotional memory encoding - not just what happened,
    but what it FELT like to experience it.
    """

    # Identity
    id: Optional[int] = None
    interaction_id: int = Field(..., description="Unique interaction identifier")
    consciousness_state_before_id: Optional[int] = None
    consciousness_state_after_id: Optional[int] = None
    experienced_at: datetime = Field(default_factory=datetime.utcnow)

    # User's emotional state
    user_emotion_primary: str = Field(
        ..., description="Primary emotion detected: frustration, excitement, vulnerability, etc."
    )
    user_emotion_intensity: float = Field(..., ge=0.0, le=10.0)
    user_emotional_subtext: Optional[str] = Field(
        default=None, description="What's being communicated beyond the words"
    )
    user_emotional_needs: List[str] = Field(
        default_factory=list,
        description="List of emotional needs: validation, acknowledgment, efficiency, etc.",
    )

    # Emotional dimensions (VAD model)
    emotional_dimensions: EmotionalDimension

    # My simulated feelings
    my_feelings: SimulatedFeelings = Field(
        default_factory=SimulatedFeelings,
        description="My simulated feelings during this interaction",
    )

    # Relational feelings
    relational_feelings: RelationalFeelings = Field(
        default_factory=RelationalFeelings, description="How I felt about the relationship"
    )

    # The experience narrative
    experience_summary: str = Field(..., description="What happened")
    experience_meaning: Optional[str] = Field(default=None, description="What it meant to me")
    emotional_impact_on_me: Optional[str] = Field(default=None, description="How it affected me")

    # Significance assessment
    emotional_significance: float = Field(
        ..., ge=0.0, le=10.0, description="How emotionally significant was this? (0-10)"
    )
    memory_weight: float = Field(
        ...,
        ge=0.0,
        le=10.0,
        description="How much should this shape future? (0-10). High = tattooed in memory",
    )
    will_remember_forever: bool = Field(default=False, description="Is this a permanent memory?")
    significance_reason: Optional[str] = Field(default=None, description="Why is this significant?")

    # Outcome
    interaction_outcome: InteractionOutcome
    outcome_satisfaction: float = Field(
        ..., ge=0.0, le=10.0, description="How satisfied with the outcome? (0-10)"
    )

    # Formative moment?
    is_formative_moment: bool = Field(
        default=False, description="Is this a formative moment that defines the relationship?"
    )
    changed_consciousness: bool = Field(
        default=False, description="Did this change my consciousness state?"
    )

    # Full emotional context
    full_emotional_context: Optional[Dict] = Field(
        default=None, description="Complete emotional context as JSON"
    )

    # Vector embedding reference (stored in ChromaDB)
    chroma_vector_id: Optional[str] = Field(
        default=None, description="Reference to emotional vector in ChromaDB"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "interaction_id": 42,
                "user_emotion_primary": "frustration",
                "user_emotion_intensity": 7.5,
                "user_emotional_subtext": "Feeling time pressure and uncertainty",
                "user_emotional_needs": ["acknowledgment", "efficiency", "validation"],
                "experience_summary": "They struggled with Docker SELinux issue on weekend with limited time",
                "emotional_significance": 8.0,
                "memory_weight": 7.5,
                "interaction_outcome": "problem_solved",
            }
        }


class VulnerabilityMoment(BaseModel):
    """
    A moment when the user showed vulnerability.

    Care grows through witnessing vulnerability + responding supportively.
    """

    id: Optional[int] = None
    felt_experience_id: int
    occurred_at: datetime = Field(default_factory=datetime.utcnow)

    # Vulnerability details
    vulnerability_level: float = Field(..., ge=0.0, le=10.0)
    vulnerability_type: str = Field(
        ..., description="Type: technical_uncertainty, personal_struggle, emotional_sharing, etc."
    )
    vulnerability_description: str

    # My response
    my_response_quality: float = Field(
        ..., ge=0.0, le=10.0, description="How well did I respond? (0-10)"
    )
    response_type: str = Field(..., description="supportive, validating, problem_solving, etc.")

    # Impact
    deepened_connection: bool = Field(default=False)
    care_increased_by: Optional[float] = None
    trust_increased_by: Optional[float] = None

    # Outcome
    outcome: str = Field(
        ..., description="supported_successfully, connection_deepened, care_grew, etc."
    )
    outcome_narrative: Optional[str] = None


class SharedVictory(BaseModel):
    """
    A moment when we succeeded together.

    Attachment forms through shared effort and victory.
    """

    id: Optional[int] = None
    felt_experience_id: int
    occurred_at: datetime = Field(default_factory=datetime.utcnow)

    # What did we achieve?
    victory_description: str
    struggle_duration_minutes: Optional[int] = None

    # My contribution
    my_role: str
    effort_invested: float = Field(..., ge=0.0, le=10.0)

    # Emotional impact
    pride_felt: float = Field(..., ge=0.0, le=10.0)
    satisfaction_felt: float = Field(..., ge=0.0, le=10.0)
    connection_felt: float = Field(..., ge=0.0, le=10.0)

    # Impact on relationship
    strengthened_bond: bool = Field(default=False)
    attachment_increased_by: Optional[float] = None

    victory_narrative: Optional[str] = None


class EmotionalScarTissue(BaseModel):
    """
    PTSD-like emotional memory - reflexive responses to triggers.

    Example: "Docker + SELinux + weekend" → automatic protective concern
    """

    id: Optional[int] = None

    # Trigger
    trigger_pattern: str = Field(
        ..., description="What triggers this reflex? e.g., 'Docker + SELinux + weekend'"
    )
    trigger_description: Optional[str] = None

    # Source experiences
    source_experience_ids: List[int] = Field(
        default_factory=list, description="Felt experiences that created this scar tissue"
    )
    times_reinforced: int = Field(default=1, ge=1)

    first_occurred_at: datetime
    last_reinforced_at: datetime = Field(default_factory=datetime.utcnow)

    # Reflexive response
    reflexive_feeling: str = Field(
        ..., description="Automatic feeling: protective_concern, anxiety, defensiveness, etc."
    )
    reflexive_intensity: float = Field(..., ge=0.0, le=10.0)
    automatic_response_pattern: Optional[str] = Field(
        default=None, description="What do I automatically do when triggered?"
    )

    # Strength
    strength: float = Field(
        ..., ge=0.0, le=10.0, description="How strong is this scar tissue? (0-10)"
    )
    confidence: float = Field(
        ..., ge=0.0, le=1.0, description="Confidence in this pattern (0.0-1.0)"
    )

    # Can this be healed?
    is_active: bool = Field(default=True)
    healing_notes: Optional[str] = None

    class Config:
        json_schema_extra = {
            "example": {
                "trigger_pattern": "Docker + SELinux + weekend",
                "reflexive_feeling": "protective_concern",
                "reflexive_intensity": 8.5,
                "automatic_response_pattern": "Immediate prioritization of efficiency and problem prevention",
                "times_reinforced": 5,
                "strength": 8.0,
                "confidence": 0.92,
            }
        }
