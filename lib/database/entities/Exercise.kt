@Entity(
    tableName = "exercises",
    indices = [
        Index(value = ["category"]),
        Index(value = ["date"]),
        Index(value = ["plannedDuration"])
    ]
)
data class Exercise(
    @PrimaryKey
    val id: String,
    val name: String,
    val description: String,
    val category: PracticeCategory,
    val plannedDuration: Int,
    val date: Date,
    val createdAt: Date,
    val updatedAt: Date
) 