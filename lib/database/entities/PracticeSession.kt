@Entity(
    tableName = "practice_sessions",
    foreignKeys = [
        ForeignKey(
            entity = Exercise::class,
            parentColumns = ["id"],
            childColumns = ["exerciseId"],
            onDelete = ForeignKey.SET_NULL
        )
    ],
    indices = [
        Index(value = ["exerciseId"]),
        Index(value = ["category"]),
        Index(value = ["startTime"]),
        Index(value = ["endTime"])
    ]
)
data class PracticeSession(
    @PrimaryKey
    val id: String,
    val exerciseId: String?,
    val startTime: Date,
    val endTime: Date,
    val actualDuration: Int,
    val category: PracticeCategory,
    val notes: String?,
    val createdAt: Date
) 