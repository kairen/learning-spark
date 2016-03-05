package com.imac;
import java.io.Serializable;
import java.util.Date;

import com.google.common.base.Objects;

 public class Person implements Serializable {
        private Integer id;
        private String name;
        private Date birthDate;

        public static Person newInstance(Integer id, String name) {
            Person person = new Person();
            person.setId(id);
            person.setName(name);
//            person.setBirthDate(birthDate);
            return person;
        }

        public Integer getId() {
            return id;
        }

        public void setId(Integer id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

//        public Date getBirthDate() {
//            return birthDate;
//        }
//
//        public void setBirthDate(Date birthDate) {
//            this.birthDate = birthDate;
//        }

        @Override
        public String toString() {
            return Objects.toStringHelper(this)
                    .add("id", id)
                    .add("name", name)
//                    .add("birthDate", birthDate)
                    .toString();
        }
    }