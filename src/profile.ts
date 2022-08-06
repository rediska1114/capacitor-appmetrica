export enum Gender {
  MALE,
  FEMALE,
  OTHER,
}

export class UserProfile {
  updates: UserProfileUpdate[] = [];

  apply(update: UserProfileUpdate) {
    this.updates.push(update);
    return this;
  }

  applyFromArray(updatesArray: UserProfileUpdate[]) {
    this.updates.push(...updatesArray);
    return this;
  }
}

export class UserProfileUpdate {
  attributeName: string;
  methodName: string;
  key: string | null;
  values: any[];

  constructor(
    attributeName: string,
    methodName: string,
    key: string | null,
    ...values: any[]
  ) {
    this.attributeName = attributeName;
    this.methodName = methodName;
    this.key = key;
    this.values = values;
  }
}

export class BirthDateAttribute {
  private attributeName = 'birthDate';
  withAge(age: number): UserProfileUpdate {
    return new UserProfileUpdate(this.attributeName, 'withAge', null, age);
  }
  withBirthDate(date: Date): UserProfileUpdate;
  withBirthDate(year: number): UserProfileUpdate;
  withBirthDate(year: number, month: number): UserProfileUpdate;
  withBirthDate(year: number, month: number, day: number): UserProfileUpdate;
  withBirthDate(
    yearOrDate: number | Date,
    month?: number,
    day?: number,
  ): UserProfileUpdate {
    const args = [];
    if (typeof yearOrDate !== 'number') {
      args.push(
        yearOrDate.getDate(),
        yearOrDate.getMonth(),
        yearOrDate.getFullYear(),
      );
    } else {
      args.push(yearOrDate);
      if (month !== undefined) args.push(month);
      if (day !== undefined) args.push(day);
    }

    return new UserProfileUpdate(
      this.attributeName,
      'withBirthDate',
      null,
      ...args,
    );
  }
  withValueReset() {
    return new UserProfileUpdate(this.attributeName, 'withValueReset', null);
  }
}

export class GenderAttribute {
  private attributeName = 'gender';

  withValue(value: Gender): UserProfileUpdate {
    return new UserProfileUpdate(
      this.attributeName,
      'withValue',
      null,
      value.toString(),
    );
  }

  withValueReset(): UserProfileUpdate {
    return new UserProfileUpdate(this.attributeName, 'withValueReset', null);
  }
}

export class NameAttribute {
  private attributeName = 'name';

  withValue(value: string): UserProfileUpdate {
    return new UserProfileUpdate(this.attributeName, 'withValue', null, value);
  }

  withValueReset(): UserProfileUpdate {
    return new UserProfileUpdate(this.attributeName, 'withValueReset', null);
  }
}
export class NotificationsEnabledAttribute {
  private attributeName = 'notificationsEnabled';

  withValue(value: boolean): UserProfileUpdate {
    return new UserProfileUpdate(this.attributeName, 'withValue', null, value);
  }

  withValueReset(): UserProfileUpdate {
    return new UserProfileUpdate(this.attributeName, 'withValueReset', null);
  }
}
export class CustomBooleanAttribute {
  private attributeName = 'customBoolean';

  key: string;

  constructor(key: string) {
    this.key = key;
  }

  withValue(value: boolean): UserProfileUpdate {
    return new UserProfileUpdate(
      this.attributeName,
      'withValue',
      this.key,
      value,
    );
  }

  withValueIfUndefined(value: boolean): UserProfileUpdate {
    return new UserProfileUpdate(
      this.attributeName,
      'withValueIfUndefined',
      this.key,
      value,
    );
  }

  withValueReset(): UserProfileUpdate {
    return new UserProfileUpdate(
      this.attributeName,
      'withValueReset',
      this.key,
    );
  }
}
export class CustomCounterAttribute {
  private attributeName = 'customCounter';

  private key: string;

  constructor(key: string) {
    this.key = key;
  }

  withDelta(value: number) {
    return new UserProfileUpdate(
      this.attributeName,
      'withDelta',
      this.key,
      value,
    );
  }
}
export class CustomNumberAttribute {
  private attributeName = 'customNumber';
  private key: string;

  constructor(key: string) {
    this.key = key;
  }

  withValue(value: number): UserProfileUpdate {
    return new UserProfileUpdate(
      this.attributeName,
      'withValue',
      this.key,
      value,
    );
  }

  withValueIfUndefined(value: number): UserProfileUpdate {
    return new UserProfileUpdate(
      this.attributeName,
      'withValueIfUndefined',
      this.key,
      value,
    );
  }

  withValueReset(): UserProfileUpdate {
    return new UserProfileUpdate(
      this.attributeName,
      'withValueReset',
      this.key,
    );
  }
}
export class CustomStringAttribute {
  private attributeName = 'customString';
  private key: string;

  constructor(key: string) {
    this.key = key;
  }

  withValue(value: string): UserProfileUpdate {
    return new UserProfileUpdate(
      this.attributeName,
      'withValue',
      this.key,
      value,
    );
  }

  withValueIfUndefined(value: string): UserProfileUpdate {
    return new UserProfileUpdate(
      this.attributeName,
      'withValueIfUndefined',
      this.key,
      value,
    );
  }

  withValueReset(): UserProfileUpdate {
    return new UserProfileUpdate(
      this.attributeName,
      'withValueReset',
      this.key,
    );
  }
}
export class ProfileAttribute {
  static BirthDate() {
    return new BirthDateAttribute();
  }
  static Gender() {
    return new GenderAttribute();
  }
  static Name() {
    return new NameAttribute();
  }
  static NotificationsEnabled() {
    return new NotificationsEnabledAttribute();
  }

  static CustomBool(key: string) {
    return new CustomBooleanAttribute(key);
  }
  static CustomCounter(key: string) {
    return new CustomCounterAttribute(key);
  }
  static CustomNumber(key: string) {
    return new CustomNumberAttribute(key);
  }
  static CustomString(key: string) {
    return new CustomStringAttribute(key);
  }
}
