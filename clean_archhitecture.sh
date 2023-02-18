#!/bin/bash
projectName="clean_architecture_cubit"
# Check if project name is provided
if [ $# -eq 0 ]; then
  echo "Error: Please provide a feature name as an argument."
  exit 1
fi

#package:${projectName}/features/

directory="lib/features"
packageName=""

if [[ -n "$1" ]]; then
  if [[ "$1" == "account" || "$1" == "admin" ]]; then
    echo "
    ########################
    This is a feature folder that you cannot use as a feature.
    ########################"
    exit 1
  fi
fi

if [[ -z "$2" ]]; then
  cd $directory
else
  if [[ "$2" != "account" && "$2" != "admin" ]]; then
    echo "
    ########################
    The feature folder has not been created yet. Please create it before attempting to use it.
    ########################"
    exit 1
  fi
  packageName="$2/"
  tempDirectory="$directory/$2"
  if [[ -d "$tempDirectory" ]]; then
    #Folder Exists
    directory=$tempDirectory
    cd $directory
  else
    #Folder not Exists
    mkdir -p $tempDirectory
    directory=$tempDirectory
    cd $directory
  fi
fi


echo "
#######################################
Change Directory to lib/features
#######################################
"

#Convert the featurename to lower case
featureName=$1

echo "Feature name : $featureName"

#Convert the featurename to snakecase
fileName="$(echo "$featureName" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\2/g' | tr '[:upper:]' '[:lower:]')"

echo "Feature file name : $fileName"

# Split the string into an array of words using the underscore as a delimiter
IFS='_' read -ra words <<< "$fileName"

# Loop through the array and capitalize the first letter of each word,
# including the first word
modelName=""
for i in "${!words[@]}"; do
  modelName+="$(echo "${words[i]:0:1}" | tr '[:lower:]' '[:upper:]')"
  modelName+="${words[i]:1}"
done
echo "Feature Model: $modelName"


if [[ -d "$featureName" ]]; then
  echo "
  #######################################
  $featureName already exists and cannot be created again.
  #######################################
  "
  exit 1
fi

mkdir $featureName

# Navigate to the project directory
cd $featureName


# Create data directory
mkdir data

# Create domain directory
mkdir domain

# Create presentation directory
mkdir presentation


# Create helper directory
mkdir helper

# Create data directory structure
mkdir -p data/datasources
mkdir -p data/models
mkdir -p data/repositories

# Create domain directory structure
mkdir -p domain/entities
mkdir -p domain/repositories
mkdir -p domain/usecases

# Create presentation directory structure
mkdir -p presentation/cubit
mkdir -p presentation/screens
mkdir -p presentation/widgets


echo "
#######################################
Switch to data layer
#######################################
"

################# RemoteData Source for feature -> data/datasources/${fileName}_remote_data_source.dart ###################
echo "Creating remote data source for ${feature}"
echo "import 'package:${projectName}/common/network/api_config.dart';
import 'package:${projectName}/common/network/api_helper.dart';
import 'package:${projectName}/common/network/dio_client.dart';
import 'package:${projectName}/di.dart';
import 'package:${projectName}/features/${packageName}${featureName}/data/models/${fileName}_model.dart';

abstract class ${modelName}RemoteDataSource {
  Future<List<${modelName}>> get${modelName}();
 }

 class ${modelName}RemoteDataSourceImpl with ApiHelper<${modelName}> implements ${modelName}RemoteDataSource {
  final DioClient dioClient = getIt<DioClient>();

  @override
  Future<List<${modelName}>> get${modelName}() async {
    final queryParameters = {};

    return await makeGetRequest(
        dioClient.dio.get(ApiConfig.comments),
        ${modelName}.fromJson);
  }
}" > "data/datasources/${fileName}_remote_data_source.dart"

################# Models for feature -> data/models/${fileName}_model.dart ###################

echo "import 'package:${projectName}/features/comment/domain/entities/comment_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:${projectName}/features/${packageName}${featureName}/domain/entities/${fileName}_entity.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart' show immutable;


part '${fileName}_model.g.dart';

@immutable
@JsonSerializable()
class ${modelName} extends ${modelName}Entity {
  const ${modelName}({
    required super.id,
  });

  factory ${modelName}.fromJson(Map<String, dynamic> json) =>
      _\$${modelName}FromJson(json);

  Map<String, dynamic> toJson() => _\$${modelName}ToJson(this);
}" > "data/models/${fileName}_model.dart"


################# Repository Implementation for feature -> data/repositories/${fileName}_repository_impl.dart ###################

echo "import 'package:${projectName}/common/network/api_result.dart';
import 'package:${projectName}/common/repository/repository_helper.dart';
import 'package:${projectName}/features/${packageName}${featureName}/data/datasources/${fileName}_remote_data_source.dart';
import 'package:${projectName}/features/${packageName}${featureName}/domain/repositories/${fileName}_repository.dart';

import 'package:${projectName}/features/${packageName}${featureName}/data/models/${fileName}_model.dart';

class ${modelName}RepositoryImpl extends ${modelName}Repository
    with RepositoryHelper<${modelName}> {
  final ${modelName}RemoteDataSource remoteDataSource;

  ${modelName}RepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<${modelName}>>> get${modelName}() async {
    return checkItemsFailOrSuccess(remoteDataSource.get${modelName}());
  }
}" > "data/repositories/${fileName}_repository_impl.dart"



echo "
#######################################
Switch to domian layer
#######################################
"

################# Entities for feature -> domain/entities/${fileName}_entity.dart ###################

echo "class ${modelName}Entity {
  const ${modelName}Entity({
    required this.id
  });

  final int id;
}" > "domain/entities/${fileName}_entity.dart"



################# Repositories for feature -> domain/repositories/${fileName}_repository.dart ###################

echo "import 'package:${projectName}/common/network/api_result.dart';

import 'package:${projectName}/features/${packageName}${featureName}/data/models/${fileName}_model.dart';

abstract class ${modelName}Repository {
  Future<ApiResult<List<${modelName}>>> get${modelName}();
}" > "domain/repositories/${fileName}_repository.dart"


################# UseCase for feature -> domain/usecases/get_${fileName}_usecase.dart ###################

echo "import 'package:${projectName}/common/network/api_result.dart';
import 'package:${projectName}/common/usecase/usecase.dart';
import 'package:${projectName}/features/${packageName}${featureName}/data/models/${fileName}_model.dart';
import 'package:${projectName}/features/${packageName}${featureName}/domain/repositories/${fileName}_repository.dart';

class Get${modelName}UseCase
    implements UseCase<List<${modelName}>, Get${modelName}Params> {
  final ${modelName}Repository repository;

  const Get${modelName}UseCase(this.repository);

  @override
  Future<ApiResult<List<${modelName}>>> call(Get${modelName}Params params) async {
    return await repository.get${modelName}();
  }
}

class Get${modelName}Params {
  Get${modelName}Params();
}" > "domain/usecases/get_${fileName}_usecase.dart"


echo "
#######################################
Switch to presentation layer
#######################################
"

################# Cubit for feature -> presentation/cubit/${fileName}_cubit.dart ###################

echo "import 'package:${projectName}/features/${packageName}${featureName}/domain/usecases/get_${fileName}_usecase.dart';
import 'package:${projectName}/features/${packageName}${featureName}/data/models/${fileName}_model.dart';
import 'package:${projectName}/common/cubit/generic_cubit.dart';

class ${modelName}Cubit extends GenericCubit<${modelName}> {
  final Get${modelName}UseCase get${modelName}UseCase;

  ${modelName}Cubit({
    required this.get${modelName}UseCase,
  });

  Future<void> get${modelName}() async {
    getItems(get${modelName}UseCase.call(Get${modelName}Params()));
  }

}" > "presentation/cubit/${fileName}_cubit.dart"


################# Screen for feature -> presentation/screens/${fileName}_home_screen.dart ###################

echo "" > "presentation/screens/${fileName}_home_screen.dart"


echo "
#######################################
Switch to helper class
#######################################
"

################# DI Class for feature -> helper/${fileName}_di.dart ###################

echo "import 'package:get_it/get_it.dart';

import 'package:${projectName}/features/${packageName}${featureName}/data/datasources/${fileName}_remote_data_source.dart';
import 'package:${projectName}/features/${packageName}${featureName}/data/repositories/${fileName}_repository_impl.dart';
import 'package:${projectName}/features/${packageName}${featureName}/domain/repositories/${fileName}_repository.dart';
import 'package:${projectName}/features/${packageName}${featureName}/domain/usecases/get_${fileName}_usecase.dart';
import 'package:${projectName}/features/${packageName}${featureName}/presentation/cubit/${fileName}_cubit.dart';

class ${modelName}Di {
  final GetIt getIt;

  ${modelName}Di(this.getIt);

  void initializeDIFor${modelName}() {

    getIt.registerFactory(
      () => ${modelName}Cubit(
        get${modelName}UseCase: getIt<Get${modelName}UseCase>(),
      ),
    );

    //  Use cases
    getIt.registerLazySingleton(
        () => Get${modelName}UseCase(getIt<${modelName}Repository>()));

    //  repository
    getIt.registerLazySingleton<${modelName}Repository>(
      () => ${modelName}RepositoryImpl(remoteDataSource: getIt()),
    );

    // Remote Datasource
    getIt.registerLazySingleton<${modelName}RemoteDataSource>(
        () => ${modelName}RemoteDataSourceImpl());
  }
}
"> "helper/${fileName}_di.dart"

flutter pub run build_runner build --delete-conflicting-outputs

echo "Project structure created successfully!"


