from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import create_engine, Column, Integer, String, Numeric, text


login = 'postgres'
password = 'admin'
engine = create_engine(f'postgresql://{login}:{password}@localhost/postgres')
with engine.connect() as connection:
    connection.execute(text('SET search_path TO shawarma'))
Session = sessionmaker(bind=engine)

Base = declarative_base()


class Employee(Base):
    __tablename__ = 'employee'
    __table_args__ = {'schema': 'shawarma'}

    employee_id = Column(Integer, primary_key=True)
    cafe_id = Column(Integer)
    employee_name = Column(String)
    employee_phone_number = Column(String)
    employee_position = Column(String)
    salary = Column(Numeric)


session = Session()

# insert: Leo Tolstoy's now in our team
new_employee = Employee(employee_id=1020, cafe_id=5, employee_name='Лев Толстой', employee_phone_number='+7 902 581-13-25', employee_position='Су-шеф', salary=150000)
session.add(new_employee)
session.commit()

# delete: Elon Musk is fired
elon_musk = session.query(Employee).filter(Employee.employee_name=='Илон Маск').first()
session.delete(elon_musk)
session.commit()

# update: Tom Cruise changed his phone number
tom_cruise= session.query(Employee).filter(Employee.employee_name=='Том Круз').first()
tom_cruise.employee_phone_number = '+7 123 456-78-90'
session.commit()

# select 2nd cafe employees
cafe2_employees = session.query(Employee).filter(Employee.cafe_id==2).all()
print("2nd cafe employees:")
for cafe2_employee in cafe2_employees:
    print(cafe2_employee.employee_name, cafe2_employee.employee_position, cafe2_employee.employee_phone_number)


