train <- fread("project/volume/data/interim/train.csv")
test <- fread("project/volume/data/interim/test.csv")
#
glm_model <- glm(result ~ total,family="binomial",data=train )

test$predResult <- predict(glm_model,newdata = test,type="response")

summary(glm_model)

saveRDS(glm_model,"project/volume/models/GLM_fitModel")




submit <- fread("project/volume/data/raw/samp_sub.csv")
submit$result <- test$predicted

fwrite(submit,"project/volume/data/processed/submission2.csv")