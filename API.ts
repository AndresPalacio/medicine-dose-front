/* tslint:disable */
/* eslint-disable */
//  This file was automatically generated and should not be edited.

export type Appointment = {
  __typename: "Appointment",
  createdAt?: string | null,
  date: string,
  description?: string | null,
  id: string,
  notes?: string | null,
  owner?: string | null,
  status?: AppointmentStatus | null,
  title: string,
  updatedAt?: string | null,
  userId: string,
};

export enum AppointmentStatus {
  cancelled = "cancelled",
  completed = "completed",
  scheduled = "scheduled",
}


export type User = {
  __typename: "User",
  createdAt?: string | null,
  email: string,
  firstName?: string | null,
  id: string,
  isEmailVerified?: boolean | null,
  lastLoginAt?: string | null,
  lastName?: string | null,
  owner?: string | null,
  phoneNumber?: string | null,
  profilePicture?: string | null,
  updatedAt?: string | null,
  username: string,
};

export type ModelAppointmentFilterInput = {
  and?: Array< ModelAppointmentFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  date?: ModelStringInput | null,
  description?: ModelStringInput | null,
  id?: ModelIDInput | null,
  not?: ModelAppointmentFilterInput | null,
  notes?: ModelStringInput | null,
  or?: Array< ModelAppointmentFilterInput | null > | null,
  owner?: ModelStringInput | null,
  status?: ModelAppointmentStatusInput | null,
  title?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  userId?: ModelStringInput | null,
};

export type ModelStringInput = {
  attributeExists?: boolean | null,
  attributeType?: ModelAttributeTypes | null,
  beginsWith?: string | null,
  between?: Array< string | null > | null,
  contains?: string | null,
  eq?: string | null,
  ge?: string | null,
  gt?: string | null,
  le?: string | null,
  lt?: string | null,
  ne?: string | null,
  notContains?: string | null,
  size?: ModelSizeInput | null,
};

export enum ModelAttributeTypes {
  _null = "_null",
  binary = "binary",
  binarySet = "binarySet",
  bool = "bool",
  list = "list",
  map = "map",
  number = "number",
  numberSet = "numberSet",
  string = "string",
  stringSet = "stringSet",
}


export type ModelSizeInput = {
  between?: Array< number | null > | null,
  eq?: number | null,
  ge?: number | null,
  gt?: number | null,
  le?: number | null,
  lt?: number | null,
  ne?: number | null,
};

export type ModelIDInput = {
  attributeExists?: boolean | null,
  attributeType?: ModelAttributeTypes | null,
  beginsWith?: string | null,
  between?: Array< string | null > | null,
  contains?: string | null,
  eq?: string | null,
  ge?: string | null,
  gt?: string | null,
  le?: string | null,
  lt?: string | null,
  ne?: string | null,
  notContains?: string | null,
  size?: ModelSizeInput | null,
};

export type ModelAppointmentStatusInput = {
  eq?: AppointmentStatus | null,
  ne?: AppointmentStatus | null,
};

export type ModelAppointmentConnection = {
  __typename: "ModelAppointmentConnection",
  items:  Array<Appointment | null >,
  nextToken?: string | null,
};

export type ModelUserFilterInput = {
  and?: Array< ModelUserFilterInput | null > | null,
  createdAt?: ModelStringInput | null,
  email?: ModelStringInput | null,
  firstName?: ModelStringInput | null,
  id?: ModelIDInput | null,
  isEmailVerified?: ModelBooleanInput | null,
  lastLoginAt?: ModelStringInput | null,
  lastName?: ModelStringInput | null,
  not?: ModelUserFilterInput | null,
  or?: Array< ModelUserFilterInput | null > | null,
  owner?: ModelStringInput | null,
  phoneNumber?: ModelStringInput | null,
  profilePicture?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  username?: ModelStringInput | null,
};

export type ModelBooleanInput = {
  attributeExists?: boolean | null,
  attributeType?: ModelAttributeTypes | null,
  eq?: boolean | null,
  ne?: boolean | null,
};

export type ModelUserConnection = {
  __typename: "ModelUserConnection",
  items:  Array<User | null >,
  nextToken?: string | null,
};

export type ModelAppointmentConditionInput = {
  and?: Array< ModelAppointmentConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  date?: ModelStringInput | null,
  description?: ModelStringInput | null,
  not?: ModelAppointmentConditionInput | null,
  notes?: ModelStringInput | null,
  or?: Array< ModelAppointmentConditionInput | null > | null,
  owner?: ModelStringInput | null,
  status?: ModelAppointmentStatusInput | null,
  title?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  userId?: ModelStringInput | null,
};

export type CreateAppointmentInput = {
  createdAt?: string | null,
  date: string,
  description?: string | null,
  id?: string | null,
  notes?: string | null,
  status?: AppointmentStatus | null,
  title: string,
  updatedAt?: string | null,
  userId: string,
};

export type ModelUserConditionInput = {
  and?: Array< ModelUserConditionInput | null > | null,
  createdAt?: ModelStringInput | null,
  email?: ModelStringInput | null,
  firstName?: ModelStringInput | null,
  isEmailVerified?: ModelBooleanInput | null,
  lastLoginAt?: ModelStringInput | null,
  lastName?: ModelStringInput | null,
  not?: ModelUserConditionInput | null,
  or?: Array< ModelUserConditionInput | null > | null,
  owner?: ModelStringInput | null,
  phoneNumber?: ModelStringInput | null,
  profilePicture?: ModelStringInput | null,
  updatedAt?: ModelStringInput | null,
  username?: ModelStringInput | null,
};

export type CreateUserInput = {
  createdAt?: string | null,
  email: string,
  firstName?: string | null,
  id?: string | null,
  isEmailVerified?: boolean | null,
  lastLoginAt?: string | null,
  lastName?: string | null,
  phoneNumber?: string | null,
  profilePicture?: string | null,
  updatedAt?: string | null,
  username: string,
};

export type DeleteAppointmentInput = {
  id: string,
};

export type DeleteUserInput = {
  id: string,
};

export type UpdateAppointmentInput = {
  createdAt?: string | null,
  date?: string | null,
  description?: string | null,
  id: string,
  notes?: string | null,
  status?: AppointmentStatus | null,
  title?: string | null,
  updatedAt?: string | null,
  userId?: string | null,
};

export type UpdateUserInput = {
  createdAt?: string | null,
  email?: string | null,
  firstName?: string | null,
  id: string,
  isEmailVerified?: boolean | null,
  lastLoginAt?: string | null,
  lastName?: string | null,
  phoneNumber?: string | null,
  profilePicture?: string | null,
  updatedAt?: string | null,
  username?: string | null,
};

export type ModelSubscriptionAppointmentFilterInput = {
  and?: Array< ModelSubscriptionAppointmentFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  date?: ModelSubscriptionStringInput | null,
  description?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  notes?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionAppointmentFilterInput | null > | null,
  owner?: ModelStringInput | null,
  status?: ModelSubscriptionStringInput | null,
  title?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  userId?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionStringInput = {
  beginsWith?: string | null,
  between?: Array< string | null > | null,
  contains?: string | null,
  eq?: string | null,
  ge?: string | null,
  gt?: string | null,
  in?: Array< string | null > | null,
  le?: string | null,
  lt?: string | null,
  ne?: string | null,
  notContains?: string | null,
  notIn?: Array< string | null > | null,
};

export type ModelSubscriptionIDInput = {
  beginsWith?: string | null,
  between?: Array< string | null > | null,
  contains?: string | null,
  eq?: string | null,
  ge?: string | null,
  gt?: string | null,
  in?: Array< string | null > | null,
  le?: string | null,
  lt?: string | null,
  ne?: string | null,
  notContains?: string | null,
  notIn?: Array< string | null > | null,
};

export type ModelSubscriptionUserFilterInput = {
  and?: Array< ModelSubscriptionUserFilterInput | null > | null,
  createdAt?: ModelSubscriptionStringInput | null,
  email?: ModelSubscriptionStringInput | null,
  firstName?: ModelSubscriptionStringInput | null,
  id?: ModelSubscriptionIDInput | null,
  isEmailVerified?: ModelSubscriptionBooleanInput | null,
  lastLoginAt?: ModelSubscriptionStringInput | null,
  lastName?: ModelSubscriptionStringInput | null,
  or?: Array< ModelSubscriptionUserFilterInput | null > | null,
  owner?: ModelStringInput | null,
  phoneNumber?: ModelSubscriptionStringInput | null,
  profilePicture?: ModelSubscriptionStringInput | null,
  updatedAt?: ModelSubscriptionStringInput | null,
  username?: ModelSubscriptionStringInput | null,
};

export type ModelSubscriptionBooleanInput = {
  eq?: boolean | null,
  ne?: boolean | null,
};

export type GetAppointmentQueryVariables = {
  id: string,
};

export type GetAppointmentQuery = {
  getAppointment?:  {
    __typename: "Appointment",
    createdAt?: string | null,
    date: string,
    description?: string | null,
    id: string,
    notes?: string | null,
    owner?: string | null,
    status?: AppointmentStatus | null,
    title: string,
    updatedAt?: string | null,
    userId: string,
  } | null,
};

export type GetUserQueryVariables = {
  id: string,
};

export type GetUserQuery = {
  getUser?:  {
    __typename: "User",
    createdAt?: string | null,
    email: string,
    firstName?: string | null,
    id: string,
    isEmailVerified?: boolean | null,
    lastLoginAt?: string | null,
    lastName?: string | null,
    owner?: string | null,
    phoneNumber?: string | null,
    profilePicture?: string | null,
    updatedAt?: string | null,
    username: string,
  } | null,
};

export type ListAppointmentsQueryVariables = {
  filter?: ModelAppointmentFilterInput | null,
  limit?: number | null,
  nextToken?: string | null,
};

export type ListAppointmentsQuery = {
  listAppointments?:  {
    __typename: "ModelAppointmentConnection",
    items:  Array< {
      __typename: "Appointment",
      createdAt?: string | null,
      date: string,
      description?: string | null,
      id: string,
      notes?: string | null,
      owner?: string | null,
      status?: AppointmentStatus | null,
      title: string,
      updatedAt?: string | null,
      userId: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type ListUsersQueryVariables = {
  filter?: ModelUserFilterInput | null,
  limit?: number | null,
  nextToken?: string | null,
};

export type ListUsersQuery = {
  listUsers?:  {
    __typename: "ModelUserConnection",
    items:  Array< {
      __typename: "User",
      createdAt?: string | null,
      email: string,
      firstName?: string | null,
      id: string,
      isEmailVerified?: boolean | null,
      lastLoginAt?: string | null,
      lastName?: string | null,
      owner?: string | null,
      phoneNumber?: string | null,
      profilePicture?: string | null,
      updatedAt?: string | null,
      username: string,
    } | null >,
    nextToken?: string | null,
  } | null,
};

export type CreateAppointmentMutationVariables = {
  condition?: ModelAppointmentConditionInput | null,
  input: CreateAppointmentInput,
};

export type CreateAppointmentMutation = {
  createAppointment?:  {
    __typename: "Appointment",
    createdAt?: string | null,
    date: string,
    description?: string | null,
    id: string,
    notes?: string | null,
    owner?: string | null,
    status?: AppointmentStatus | null,
    title: string,
    updatedAt?: string | null,
    userId: string,
  } | null,
};

export type CreateUserMutationVariables = {
  condition?: ModelUserConditionInput | null,
  input: CreateUserInput,
};

export type CreateUserMutation = {
  createUser?:  {
    __typename: "User",
    createdAt?: string | null,
    email: string,
    firstName?: string | null,
    id: string,
    isEmailVerified?: boolean | null,
    lastLoginAt?: string | null,
    lastName?: string | null,
    owner?: string | null,
    phoneNumber?: string | null,
    profilePicture?: string | null,
    updatedAt?: string | null,
    username: string,
  } | null,
};

export type DeleteAppointmentMutationVariables = {
  condition?: ModelAppointmentConditionInput | null,
  input: DeleteAppointmentInput,
};

export type DeleteAppointmentMutation = {
  deleteAppointment?:  {
    __typename: "Appointment",
    createdAt?: string | null,
    date: string,
    description?: string | null,
    id: string,
    notes?: string | null,
    owner?: string | null,
    status?: AppointmentStatus | null,
    title: string,
    updatedAt?: string | null,
    userId: string,
  } | null,
};

export type DeleteUserMutationVariables = {
  condition?: ModelUserConditionInput | null,
  input: DeleteUserInput,
};

export type DeleteUserMutation = {
  deleteUser?:  {
    __typename: "User",
    createdAt?: string | null,
    email: string,
    firstName?: string | null,
    id: string,
    isEmailVerified?: boolean | null,
    lastLoginAt?: string | null,
    lastName?: string | null,
    owner?: string | null,
    phoneNumber?: string | null,
    profilePicture?: string | null,
    updatedAt?: string | null,
    username: string,
  } | null,
};

export type UpdateAppointmentMutationVariables = {
  condition?: ModelAppointmentConditionInput | null,
  input: UpdateAppointmentInput,
};

export type UpdateAppointmentMutation = {
  updateAppointment?:  {
    __typename: "Appointment",
    createdAt?: string | null,
    date: string,
    description?: string | null,
    id: string,
    notes?: string | null,
    owner?: string | null,
    status?: AppointmentStatus | null,
    title: string,
    updatedAt?: string | null,
    userId: string,
  } | null,
};

export type UpdateUserMutationVariables = {
  condition?: ModelUserConditionInput | null,
  input: UpdateUserInput,
};

export type UpdateUserMutation = {
  updateUser?:  {
    __typename: "User",
    createdAt?: string | null,
    email: string,
    firstName?: string | null,
    id: string,
    isEmailVerified?: boolean | null,
    lastLoginAt?: string | null,
    lastName?: string | null,
    owner?: string | null,
    phoneNumber?: string | null,
    profilePicture?: string | null,
    updatedAt?: string | null,
    username: string,
  } | null,
};

export type OnCreateAppointmentSubscriptionVariables = {
  filter?: ModelSubscriptionAppointmentFilterInput | null,
  owner?: string | null,
};

export type OnCreateAppointmentSubscription = {
  onCreateAppointment?:  {
    __typename: "Appointment",
    createdAt?: string | null,
    date: string,
    description?: string | null,
    id: string,
    notes?: string | null,
    owner?: string | null,
    status?: AppointmentStatus | null,
    title: string,
    updatedAt?: string | null,
    userId: string,
  } | null,
};

export type OnCreateUserSubscriptionVariables = {
  filter?: ModelSubscriptionUserFilterInput | null,
  owner?: string | null,
};

export type OnCreateUserSubscription = {
  onCreateUser?:  {
    __typename: "User",
    createdAt?: string | null,
    email: string,
    firstName?: string | null,
    id: string,
    isEmailVerified?: boolean | null,
    lastLoginAt?: string | null,
    lastName?: string | null,
    owner?: string | null,
    phoneNumber?: string | null,
    profilePicture?: string | null,
    updatedAt?: string | null,
    username: string,
  } | null,
};

export type OnDeleteAppointmentSubscriptionVariables = {
  filter?: ModelSubscriptionAppointmentFilterInput | null,
  owner?: string | null,
};

export type OnDeleteAppointmentSubscription = {
  onDeleteAppointment?:  {
    __typename: "Appointment",
    createdAt?: string | null,
    date: string,
    description?: string | null,
    id: string,
    notes?: string | null,
    owner?: string | null,
    status?: AppointmentStatus | null,
    title: string,
    updatedAt?: string | null,
    userId: string,
  } | null,
};

export type OnDeleteUserSubscriptionVariables = {
  filter?: ModelSubscriptionUserFilterInput | null,
  owner?: string | null,
};

export type OnDeleteUserSubscription = {
  onDeleteUser?:  {
    __typename: "User",
    createdAt?: string | null,
    email: string,
    firstName?: string | null,
    id: string,
    isEmailVerified?: boolean | null,
    lastLoginAt?: string | null,
    lastName?: string | null,
    owner?: string | null,
    phoneNumber?: string | null,
    profilePicture?: string | null,
    updatedAt?: string | null,
    username: string,
  } | null,
};

export type OnUpdateAppointmentSubscriptionVariables = {
  filter?: ModelSubscriptionAppointmentFilterInput | null,
  owner?: string | null,
};

export type OnUpdateAppointmentSubscription = {
  onUpdateAppointment?:  {
    __typename: "Appointment",
    createdAt?: string | null,
    date: string,
    description?: string | null,
    id: string,
    notes?: string | null,
    owner?: string | null,
    status?: AppointmentStatus | null,
    title: string,
    updatedAt?: string | null,
    userId: string,
  } | null,
};

export type OnUpdateUserSubscriptionVariables = {
  filter?: ModelSubscriptionUserFilterInput | null,
  owner?: string | null,
};

export type OnUpdateUserSubscription = {
  onUpdateUser?:  {
    __typename: "User",
    createdAt?: string | null,
    email: string,
    firstName?: string | null,
    id: string,
    isEmailVerified?: boolean | null,
    lastLoginAt?: string | null,
    lastName?: string | null,
    owner?: string | null,
    phoneNumber?: string | null,
    profilePicture?: string | null,
    updatedAt?: string | null,
    username: string,
  } | null,
};
