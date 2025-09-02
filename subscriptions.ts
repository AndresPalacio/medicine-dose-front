/* tslint:disable */
/* eslint-disable */
// this is an auto generated file. This will be overwritten

import * as APITypes from "./API";
type GeneratedSubscription<InputType, OutputType> = string & {
  __generatedSubscriptionInput: InputType;
  __generatedSubscriptionOutput: OutputType;
};

export const onCreateAppointment = /* GraphQL */ `subscription OnCreateAppointment(
  $filter: ModelSubscriptionAppointmentFilterInput
  $owner: String
) {
  onCreateAppointment(filter: $filter, owner: $owner) {
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
` as GeneratedSubscription<
  APITypes.OnCreateAppointmentSubscriptionVariables,
  APITypes.OnCreateAppointmentSubscription
>;
export const onCreateUser = /* GraphQL */ `subscription OnCreateUser(
  $filter: ModelSubscriptionUserFilterInput
  $owner: String
) {
  onCreateUser(filter: $filter, owner: $owner) {
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
` as GeneratedSubscription<
  APITypes.OnCreateUserSubscriptionVariables,
  APITypes.OnCreateUserSubscription
>;
export const onDeleteAppointment = /* GraphQL */ `subscription OnDeleteAppointment(
  $filter: ModelSubscriptionAppointmentFilterInput
  $owner: String
) {
  onDeleteAppointment(filter: $filter, owner: $owner) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteAppointmentSubscriptionVariables,
  APITypes.OnDeleteAppointmentSubscription
>;
export const onDeleteUser = /* GraphQL */ `subscription OnDeleteUser(
  $filter: ModelSubscriptionUserFilterInput
  $owner: String
) {
  onDeleteUser(filter: $filter, owner: $owner) {
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
` as GeneratedSubscription<
  APITypes.OnDeleteUserSubscriptionVariables,
  APITypes.OnDeleteUserSubscription
>;
export const onUpdateAppointment = /* GraphQL */ `subscription OnUpdateAppointment(
  $filter: ModelSubscriptionAppointmentFilterInput
  $owner: String
) {
  onUpdateAppointment(filter: $filter, owner: $owner) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateAppointmentSubscriptionVariables,
  APITypes.OnUpdateAppointmentSubscription
>;
export const onUpdateUser = /* GraphQL */ `subscription OnUpdateUser(
  $filter: ModelSubscriptionUserFilterInput
  $owner: String
) {
  onUpdateUser(filter: $filter, owner: $owner) {
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
` as GeneratedSubscription<
  APITypes.OnUpdateUserSubscriptionVariables,
  APITypes.OnUpdateUserSubscription
>;
