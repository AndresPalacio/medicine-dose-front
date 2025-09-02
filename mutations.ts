/* tslint:disable */
/* eslint-disable */
// this is an auto generated file. This will be overwritten

import * as APITypes from "./API";
type GeneratedMutation<InputType, OutputType> = string & {
  __generatedMutationInput: InputType;
  __generatedMutationOutput: OutputType;
};

export const createAppointment = /* GraphQL */ `mutation CreateAppointment(
  $condition: ModelAppointmentConditionInput
  $input: CreateAppointmentInput!
) {
  createAppointment(condition: $condition, input: $input) {
    createdAt
    date
    description
    id
    notes
    owner
    status
    title
    updatedAt
    userId
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateAppointmentMutationVariables,
  APITypes.CreateAppointmentMutation
>;
export const createUser = /* GraphQL */ `mutation CreateUser(
  $condition: ModelUserConditionInput
  $input: CreateUserInput!
) {
  createUser(condition: $condition, input: $input) {
    createdAt
    email
    firstName
    id
    isEmailVerified
    lastLoginAt
    lastName
    owner
    phoneNumber
    profilePicture
    updatedAt
    username
    __typename
  }
}
` as GeneratedMutation<
  APITypes.CreateUserMutationVariables,
  APITypes.CreateUserMutation
>;
export const deleteAppointment = /* GraphQL */ `mutation DeleteAppointment(
  $condition: ModelAppointmentConditionInput
  $input: DeleteAppointmentInput!
) {
  deleteAppointment(condition: $condition, input: $input) {
    createdAt
    date
    description
    id
    notes
    owner
    status
    title
    updatedAt
    userId
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteAppointmentMutationVariables,
  APITypes.DeleteAppointmentMutation
>;
export const deleteUser = /* GraphQL */ `mutation DeleteUser(
  $condition: ModelUserConditionInput
  $input: DeleteUserInput!
) {
  deleteUser(condition: $condition, input: $input) {
    createdAt
    email
    firstName
    id
    isEmailVerified
    lastLoginAt
    lastName
    owner
    phoneNumber
    profilePicture
    updatedAt
    username
    __typename
  }
}
` as GeneratedMutation<
  APITypes.DeleteUserMutationVariables,
  APITypes.DeleteUserMutation
>;
export const updateAppointment = /* GraphQL */ `mutation UpdateAppointment(
  $condition: ModelAppointmentConditionInput
  $input: UpdateAppointmentInput!
) {
  updateAppointment(condition: $condition, input: $input) {
    createdAt
    date
    description
    id
    notes
    owner
    status
    title
    updatedAt
    userId
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateAppointmentMutationVariables,
  APITypes.UpdateAppointmentMutation
>;
export const updateUser = /* GraphQL */ `mutation UpdateUser(
  $condition: ModelUserConditionInput
  $input: UpdateUserInput!
) {
  updateUser(condition: $condition, input: $input) {
    createdAt
    email
    firstName
    id
    isEmailVerified
    lastLoginAt
    lastName
    owner
    phoneNumber
    profilePicture
    updatedAt
    username
    __typename
  }
}
` as GeneratedMutation<
  APITypes.UpdateUserMutationVariables,
  APITypes.UpdateUserMutation
>;
